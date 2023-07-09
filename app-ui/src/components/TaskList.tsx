import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { baseUrl } from '@/config';
import { useRouter } from 'next/router';

interface Task {
  task_id: number;
  activity_id: number;
  name: string;
  start_time: string;
  end_time: string;
  duration: number;
}

interface TaskListProps {
  activityId: number;
}

const TaskList: React.FC<TaskListProps> = ({ activityId }) => {

  const router = useRouter()
  const [tasks, setTasks] = useState<Task[]>([]);

  useEffect(() => {
    fetchTasks();
  }, [activityId]);

  const fetchTasks = async () => {
    try {
      const response = await axios.get(`${baseUrl}/api/tasks/activity/${activityId}/`);
      setTasks(response.data);
    } catch (error) {
      console.error('Failed to fetch tasks:', error);
    }
  };

  const removeTask = async (taskId: number) => {
    try {
      await axios.delete(`${baseUrl}/api/tasks/${taskId}/`);
      setTasks(tasks.filter((task) => task.task_id !== taskId));
    } catch (error) {
      console.error('Failed to remove task:', error);
    }
  };

  return (
    <div className="p-4">
      <div className="mb-4">
        <h2 className="text-2xl font-bold">Tasks List</h2>
        <div className="flex items-center justify-start mb-4 space-x-2">
          <button
            type="button"
            className="px-3 py-1  text-white bg-blue-500 hover:bg-blue-600"
            name="btnnew"
            id="btnnew"
            onClick={() => router.push(`/tasks/task/${activityId}/0`)}>
            New Task
          </button>
        </div>
      </div>
      <div className="overflow-x-auto shadow-md">
        <table className="min-w-full table-auto border-collapse border border-slate-200">
          <thead className="font-bold">
            <tr>
              <th className="py-2 border border-slate-200 text-gray-700 text-sm font-bold">#ID</th>
              <th className="py-2 border border-slate-200 text-left text-gray-700 text-sm font-bold">Start time</th>
              <th className="py-2 border border-slate-200 text-left text-gray-700 text-sm font-bold">End time</th>
              <th className="py-2 border border-slate-200 text-gray-700 text-sm font-bold">Duration</th>
              <th className="py-2 border border-slate-200 text-gray-700 text-sm font-bold">Actions</th>
            </tr>
          </thead>
          <tbody>
            {tasks.map((task) => (
              <tr key={task.task_id}>
                <td className="py-2 border border-slate-200 text-center">{task.task_id}</td>
                <td className="py-2 border border-slate-200">{task.name}</td>
                <td className="py-2 border border-slate-200">{task.start_time}</td>
                <td className="py-2 border border-slate-200 text-center">{task.end_time}h</td>
                <td className="py-2 border border-slate-200 text-center">{task.duration}h</td>
                <td className="flex py-2 border border-slate-200 justify-end space-x-1">
                  <button
                    type="button"
                    className="px-3 py-1 text-white bg-slate-500 rounded-md hover:bg-slate-600">
                    Work
                  </button>
                  <button
                    type="button"
                    onClick={() => router.push(`/tasks/task/${activityId}/${task.task_id}`)}
                    className="px-3 py-1 text-white bg-green-500 rounded-md hover:bg-green-600">
                    Edit
                  </button>
                  <button
                    type="button"
                    className="px-3 py-1 text-white bg-red-500 rounded-md hover:bg-red-600"
                    onClick={() => removeTask(task.task_id)}>
                    Remove
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default TaskList;