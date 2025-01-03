import React, { useState } from 'react';
import { Search, UserCircle } from "lucide-react";
import { UserData } from "@/types";
import { useAuth } from '@/hooks/useAuth/useAuth';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { useDraggable } from '@dnd-kit/core';
import { cn } from '@/lib/utils';
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip';
import { Separator } from '@/components/ui/separator';

interface MembersListProps {
	members: UserData[] | null;
}

interface DraggableMemberCardProps {
	member: UserData;
	isCurrentUser: boolean;
}


const MemberCard: React.FC<{
	member: UserData;
	isCurrentUser: boolean;
	className?: string;
}> = ({ member, isCurrentUser, className = '' }) => (
	<TooltipProvider>
		<Tooltip>
			<TooltipTrigger asChild>
				<div
					className={`
            group flex items-center gap-3 p-3 rounded-lg w-full
            transition-all duration-200 ease-in-out
            ${isCurrentUser ? 'bg-blue-50/80 hover:bg-blue-100/90 border border-blue-200' :
							'hover:bg-gray-50 border border-transparent hover:border-gray-200'}
            ${className}
          `}
				>
					<div className="flex-shrink-0 relative">
						<img
							src="https://img.freepik.com/premium-vector/anonymous-user-circle-icon-vector-illustration-flat-style-with-long-shadow_520826-1931.jpg?w=1800"
							alt={`${member.first_name} ${member.last_name}`}
							className={`
                h-8 w-8 rounded-full object-cover
                ${isCurrentUser ? 'ring-2 ring-blue-400 ring-offset-2' :
									'group-hover:ring-2 group-hover:ring-gray-200 group-hover:ring-offset-1'}
              `}
							draggable={false}
						/>
						{isCurrentUser && (
							<div className="absolute -top-1 -right-1 bg-blue-500 rounded-full w-3 h-3 border-2 border-white" />
						)}
					</div>
					<div className="min-w-0 flex-1">
						<p className={`
              text-sm font-medium truncate
              ${isCurrentUser ? 'text-blue-900' : 'text-gray-900'}
            `}>
							{member.first_name} {member.last_name}
							{isCurrentUser && (
								<span className="block text-xs font-normal text-blue-600">
									(You)
								</span>
							)}
						</p>
					</div>
				</div>
			</TooltipTrigger>
			<TooltipContent side="right" className="flex gap-2 p-4">
				<div className="space-y-1">
					<p className="text-xs font-medium text-gray-500 uppercase">Role</p>
					<p className="text-sm font-medium">{member.user_role.toUpperCase()}</p>
				</div>
				<div>
					<Separator orientation="vertical" />
				</div>
				<div className="space-y-1">
					<p className="text-xs font-medium text-gray-500 uppercase">Team</p>
					<p className="text-sm font-medium">{member.team_name}</p>
				</div>
			</TooltipContent>
		</Tooltip>
	</TooltipProvider>
);

const DraggableMemberCard: React.FC<DraggableMemberCardProps> = ({ member, isCurrentUser }) => {
	const { attributes, listeners, setNodeRef, isDragging } = useDraggable({
		id: `member-${member.id}`,
		data: {
			type: 'new-member',
			member
		}
	});

	return (
		<div
			ref={setNodeRef}
			{...listeners}
			{...attributes}
			className={cn(
				"xl:w-full w-40 shrink-0 relative touch-none",
				isDragging && "pointer-events-none"
			)}
			style={{ height: '72px' }}
		>
			<div className={cn(
				"absolute inset-0 transition-all duration-200",
				isDragging ? "opacity-0" : "opacity-100"
			)}>
				<MemberCard
					member={member}
					isCurrentUser={isCurrentUser}
					className={`cursor-grab active:cursor-grabbing ${isDragging ? 'pointer-events-none' : ''}`}
				/>
			</div>
		</div>
	);
};

const EmptyState: React.FC<{ searchActive?: boolean }> = ({ searchActive }) => (
	<div className="flex flex-col items-center justify-center h-48 px-4">
		<UserCircle className="h-12 w-12 mb-3 text-gray-400" />
		<p className="text-sm text-gray-500 text-center">
			{searchActive
				? "No members found matching your search"
				: "No members in this list yet"}
		</p>
	</div>
);

const MembersList: React.FC<MembersListProps> = ({ members }) => {
	const { user } = useAuth();
	const [searchQuery, setSearchQuery] = useState("");

	const filteredMembers = members?.filter(member =>
		`${member.first_name} ${member.last_name} ${member.team_name} ${member.user_role}`
			.toLowerCase()
			.includes(searchQuery.toLowerCase())
	);

	return (
		<Card className="h-full flex flex-col border-0 shadow-none">
			<CardContent className="flex-1 flex flex-col p-4 h-full">
				<div className="mb-4 flex-shrink-0">
					<div className="relative">
						<Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
						<Input
							placeholder="Search members..."
							value={searchQuery}
							onChange={(e) => setSearchQuery(e.target.value)}
							className="w-full pl-9 bg-gray-50 border-gray-200 focus:bg-white transition-colors duration-200"
						/>
					</div>
				</div>

				{!filteredMembers || filteredMembers.length === 0 ? (
					<EmptyState searchActive={searchQuery.length > 0} />
				) : (
					<div className="flex flex-row xl:flex-col gap-2 pr-4 xl:pr-0 overflow-x-auto xl:overflow-x-visible">
						{filteredMembers.map((member) => (
							<DraggableMemberCard
								key={member.id}
								member={member}
								isCurrentUser={member.id === user?.id}
							/>
						))}
					</div>
				)}
			</CardContent>
		</Card>
	);
};

export default MembersList;
