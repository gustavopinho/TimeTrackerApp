import { baseUrl } from '@/config';
import axios from 'axios';
import { useRouter } from 'next/router';
import React, { ChangeEvent, FormEvent, useEffect, useState } from 'react';

interface Task {
  task_id?: number;
  activity_id: number;
  name: string;
}

const Task: React.FC = () => {
  const router = useRouter();
  const activityId = parseInt(router.query.activityId as string, 10);
  const id = parseInt(router.query.id as string, 10);

  const [task, setTask] = useState<Task>({
    name: '',
    activity_id: activityId
  });

  useEffect(() => {
    if (id > 0) {
      fetchTask();
    }
  }, [])

  const fetchTask = async () => {
    try {
      const response = await axios.get(`${baseUrl}/api/tasks/${id}/`);
      setTask(response.data)
    } catch (error) {
      console.error('Failed to fetch task:', error);
    }
  }

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setTask((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    
    try {
      if (id === 0) {
        await axios.post(`${baseUrl}/api/tasks/`, task);
      } else {
        await axios.put(`${baseUrl}/api/tasks/${id}/`, task);
      }
      router.push(`/tasks/${activityId}`);

    } catch (error) {
      console.error('Failed to add activity:', error);
    }
  };

  return (
    <div className="w-6/12 mx-auto">
      <h2 className="text-2xl font-bold">Add/Edit Task</h2>
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label className="block text-gray-700 text-sm font-bold mb-2" htmlFor="name">Name:</label>
          <input
            value={task?.name}
            onChange={handleChange}
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            id="name"
            name="name"
            type="text"
            required
            placeholder="Enter with the name" />
        </div>
        <div className="flex items-center justify-end space-x-1">
          <button onClick={() => router.push(`/tasks/${activityId}`)} className="bg-green-500 hover:bg-green-700 text-white py-2 px-4 rounded focus:outline-none focus:shadow-outline" type="button">Back</button>
          <button className="bg-blue-500 hover:bg-blue-700 text-white py-2 px-4 rounded focus:outline-none focus:shadow-outline" type="submit">Save</button>
        </div>
      </form>
    </div>
  );
}

export default Task;