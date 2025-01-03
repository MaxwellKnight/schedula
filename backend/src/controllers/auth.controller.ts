import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import * as dotenv from 'dotenv';
import { UserService } from '../services';
import { RowDataPacket, ResultSetHeader } from 'mysql2';
import { Database } from '../configs/db.config';
import { Response, Request, NextFunction } from 'express';
import { TokenPayload } from '../middlewares/middlewares';

dotenv.config();

interface ExpiredToken extends RowDataPacket {
	id: number;
	token: string;
	created_at: Date;
}

export class AuthController {
	private readonly service: UserService;
	private readonly salt: number;
	private readonly db: Database;

	constructor(service: UserService) {
		this.service = service;
		this.salt = 12;
		this.db = Database.instance;
	}

	generateTokens = (user: TokenPayload) => {
		if (!user.email) {
			throw new Error('Missing email in user data');
		}

		const payload = {
			id: user.id,
			email: user.email,
			googleId: user.google_id,
			display_name: user.display_name,
			picture: user.picture
		};

		const accessToken = jwt.sign(
			payload,
			process.env.ACCESS_TOKEN_SECRET!,
			{ expiresIn: '1h' }
		);

		const refreshToken = jwt.sign(
			payload,
			process.env.REFRESH_TOKEN_SECRET!,
			{ expiresIn: '7d' }
		);

		return { accessToken, refreshToken };
	};

	public async saveRefreshToken(token: string): Promise<void> {
		try {
			await this.db.execute<ResultSetHeader>(
				'INSERT INTO expired (token, created_at) VALUES (?, NOW())',
				[token]
			);
		} catch (error) {
			console.error('Error saving refresh token:', error);
			throw new Error('Failed to save refresh token');
		}
	}

	public callback = async (req: Request, res: Response): Promise<void> => {
		try {
			if (!req.user || !req.user.email) {
				throw new Error('No user data from Google authentication');
			}

			const user = await this.service.getByEmail(req.user?.email);
			const tokens = this.generateTokens(user || req.user);
			const redirectUrl = new URL(`${process.env.FRONTEND_URL}/auth/callback`);

			redirectUrl.searchParams.append('accessToken', tokens.accessToken);
			redirectUrl.searchParams.append('refreshToken', tokens.refreshToken);

			await this.saveRefreshToken(tokens.refreshToken);

			res.redirect(redirectUrl.toString());
		} catch (error) {
			console.error('Google auth callback error:', error);
			res.redirect(`${process.env.FRONTEND_URL}/login?error=authentication-failed`);
		}
	}

	private async isTokenExpired(token: string): Promise<boolean> {
		const [result] = await this.db.execute<ExpiredToken[]>(
			'SELECT * FROM expired WHERE token = ?',
			[token]
		);
		return result.length > 0;
	}

	private async cleanupExpiredTokens(): Promise<void> {
		try {
			await this.db.execute<ResultSetHeader>(
				'DELETE FROM expired WHERE created_at < DATE_SUB(NOW(), INTERVAL 7 DAY)'
			);
		} catch (error) {
			console.error('Error cleaning up expired tokens:', error);
		}
	}

	public login = async (req: Request, res: Response) => {
		try {
			const { email, password } = req.body;
			if (!email || !password)
				return res.status(400).json({ message: 'Email and password are required' });

			const user = await this.service.getByEmail(email);
			if (!user)
				return res.status(401).json({ message: 'Incorrect email or password' });

			const result = await new Promise<boolean>((resolve, reject) => {
				bcrypt.compare(password, user.password, (err, result) => {
					if (err) reject(err);
					resolve(result);
				});
			});

			if (!result) return res.status(401).json({ message: 'Incorrect email or password' });

			const { id, google_id, display_name, picture } = user;
			const tokens = this.generateTokens({ id, google_id, display_name, picture, email });

			await this.saveRefreshToken(tokens.refreshToken);
			await this.cleanupExpiredTokens();

			res.json({
				accessToken: tokens.accessToken,
				refreshToken: tokens.refreshToken
			});
		} catch (error) {
			console.error('Login error:', error);
			res.status(500).json({ message: 'Internal server error' });
		}
	}

	public authenticate = async (req: Request, res: Response, next: NextFunction) => {
		try {
			const { authorization } = req.headers;
			const token = authorization && authorization.split(' ')[1];

			if (!token) return res.status(401).json({ message: 'Unauthorized access' });

			const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET!);
			req.user = decoded as TokenPayload;
			next();
		} catch (err) {
			return res.status(403).json({ message: 'Invalid token' });
		}
	}

	public refresh = async (req: Request, res: Response) => {
		try {
			const { refreshToken } = req.body;

			if (!refreshToken) {
				return res.status(401).json({ message: 'Refresh token required' });
			}

			const isInExpiredList = await this.isTokenExpired(refreshToken);
			if (isInExpiredList) {
				return res.status(403).json({ message: 'Refresh token has been revoked' });
			}

			try {
				const decoded = jwt.verify(
					refreshToken,
					process.env.REFRESH_TOKEN_SECRET!
				) as TokenPayload;

				const tokens = this.generateTokens(decoded);
				await this.saveRefreshToken(refreshToken);
				await this.saveRefreshToken(tokens.refreshToken);

				res.json({
					accessToken: tokens.accessToken,
					refreshToken: tokens.refreshToken
				});
			} catch (jwtError) {
				return res.status(403).json({ message: 'Invalid or expired refresh token' });
			}
		} catch (err) {
			console.error('Refresh token error:', err);
			return res.status(500).json({ message: 'Internal server error' });
		}
	}

	public logout = async (req: Request, res: Response) => {
		try {
			const { refreshToken } = req.body;

			if (!refreshToken) {
				return res.status(400).json({ message: 'Refresh token required' });
			}

			await this.saveRefreshToken(refreshToken);
			res.json({ message: 'Logged out successfully' });
		} catch (err) {
			console.error('Logout error:', err);
			res.status(500).json({ message: 'Error logging out' });
		}
	}

	public register = async (req: Request, res: Response) => {
		const { email, password, ...rest } = req.body;
		const user = await this.service.getByEmail(email);

		if (user) return res.status(409).json({ message: 'User already exists' });

		const hashed = await new Promise<string>((resolve, reject) => {
			bcrypt.hash(password, this.salt, (err, hash) => {
				if (err) reject(err);
				resolve(hash);
			});
		});

		const newId = await this.service.create({ email, password: hashed, ...rest });
		if (!newId)
			return res.status(500).json({ message: 'Error creating user' });

		res.json({ message: 'Registered successfully.', id: newId });
	}
}
