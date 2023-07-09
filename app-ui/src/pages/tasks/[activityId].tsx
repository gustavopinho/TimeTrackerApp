import React from 'react';
import { useRouter } from 'next/router';
import TaskList from '@/components/TaskList';

const Tasks: React.FC = () => { 
    const router = useRouter();
    const activityId = parseInt(router.query.activityId as string, 10);

    return (
        <>
            <TaskList activityId={activityId} />
        </>
    );
}

export default Tasks;