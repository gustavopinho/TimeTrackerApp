import React, { ChangeEvent, FormEvent, useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import axios from 'axios';
import { baseUrl } from '@/config';

interface Activity {
  activity_id?: number;
  name: string;
  original_estimate: number;
}

const Activity: React.FC = () => {
  const router = useRouter();
  const id = parseInt(router.query.id as string, 10);

  const [activity, setActivity] = useState<Activity>({
    name: '',
    original_estimate: 0,
  });

  useEffect(() => {
    if (id > 0) {
      fetchActivity();
    }
  }, [])

  const fetchActivity = async () => {
    try {
      const response = await axios.get(`${baseUrl}/api/activities/${id}/`);
      setActivity(response.data)
    } catch (error) {
      console.error('Failed to fetch activity:', error);
    }
  }

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setActivity((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    try {
      if (id === 0) {
        await axios.post(`${baseUrl}/api/activities/`, activity);
      } else {
        await axios.put(`${baseUrl}/api/activities/${id}/`, activity);
      }
      router.push('/');

    } catch (error) {
      console.error('Failed to add activity:', error);
    }
  };

  return (
    <div className="w-6/12 mx-auto">
      <h2 className="text-2xl font-bold">Add/Edit Activity</h2>
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label className="block text-gray-700 text-sm font-bold mb-2" htmlFor="name">Name:</label>
          <input
            value={activity?.name}
            onChange={handleChange}
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            id="name"
            name="name"
            type="text"
            required
            placeholder="Enter with the name" />
        </div>
        <div className="mb-4">
          <label className="block text-gray-700 text-sm font-bold mb-2" htmlFor="original_estimate">Original Estimate:</label>
          <input
            value={activity?.original_estimate}
            onChange={handleChange}
            className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            id="original_estimate"
            name="original_estimate"
            type="number"
            required
            placeholder="Enter the estimate" />
        </div>
        <div className="flex items-center justify-end space-x-1">
          <button onClick={() => router.push("/")} className="bg-green-500 hover:bg-green-700 text-white py-2 px-4 rounded focus:outline-none focus:shadow-outline" type="button">Back</button>
          <button className="bg-blue-500 hover:bg-blue-700 text-white py-2 px-4 rounded focus:outline-none focus:shadow-outline" type="submit">Save</button>
        </div>
      </form>
    </div>
  );
};

export default Activity;