import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { baseUrl } from '@/config';
import { useRouter } from 'next/router';

interface Activity {
  activity_id?: number;
  name: string;
  original_estimate: number;
  remaining_hours: number;
  completed_hours: number;
}

const ActivityList: React.FC = () => {
  const [activities, setActivities] = useState<Activity[]>([]);
  const router = useRouter()

  useEffect(() => {
    fetchActivities();
  }, []);

  // Actions
  const fetchActivities = async () => {
    try {
      const response = await axios.get(`${baseUrl}/api/activities/`);
      setActivities(response.data);
    } catch (error) {
      console.error('Failed to fetch activities:', error);
    }
  };

  const deleteActivity = async (activityId: number | undefined) => {
    try {
      await axios.delete(`${baseUrl}/api/activities/${activityId}/`);
      setActivities(activities.filter((activity) => activity.activity_id !== activityId));
    } catch (error) {
      console.error('Failed to remove activity:', error);
    }
  };

  return (
    <div className="p-4">
      <div className="mb-4">
        <h2 className="text-2xl font-bold">Activity List</h2>

        <div className="flex items-center justify-start mb-4 space-x-2">
          <button
            type="button"
            className="px-3 py-1  text-white bg-blue-500 hover:bg-blue-600"
            name="btnnew"
            id="btnnew"
            onClick={() => router.push('/activity/0')}>
            New Activity
          </button>
          <input type="text" className="px-3 py-1 border border-gray-300" name="search" id="search" placeholder="Search" />
          <button type="button" className="px-3 py-1 text-white bg-yellow-600 hover:bg-yellow-600" name="btnsearch" id="btnsearch">Search</button>
        </div>
      </div>
      <div className="overflow-x-auto shadow-md">
        <table className="min-w-full table-auto border-collapse border border-slate-200">
          <thead className="font-bold">
            <tr>
              <th className="py-2 border border-slate-200 text-gray-700 text-sm font-bold">#ID</th>
              <th className="py-2 border border-slate-200 text-left text-gray-700 text-sm font-bold">Name</th>
              <th className="py-2 border border-slate-200 text-left text-gray-700 text-sm font-bold">Status</th>
              <th className="py-2 border border-slate-200 text-gray-700 text-sm font-bold">Original</th>
              <th className="py-2 border border-slate-200 text-gray-700 text-sm font-bold">Remaining</th>
              <th className="py-2 border border-slate-200 text-gray-700 text-sm font-bold">Completed</th>
              <th className="py-2 border border-slate-200 text-gray-700 text-sm font-bold">Actions</th>
            </tr>
          </thead>
          <tbody>
            {activities.map((activity) => (
              <tr key={activity.activity_id}>
                <td className="py-2 border border-slate-200 text-center">{activity.activity_id}</td>
                <td className="py-2 border border-slate-200">{activity.name}</td>
                <td className="py-2 border border-slate-200">Status</td>
                <td className="py-2 border border-slate-200 text-center">{activity.original_estimate}h</td>
                <td className="py-2 border border-slate-200 text-center">{activity.remaining_hours}h</td>
                <td className="py-2 border border-slate-200 text-center">{activity.completed_hours}h</td>
                <td className="flex py-2 border border-slate-200 justify-end space-x-1">
                  <button
                    type="button"
                    className="px-3 py-1 text-white bg-slate-500 rounded-md hover:bg-slate-600"
                    onClick={() => router.push(`/tasks/${activity.activity_id}`)}>
                    Tasks
                  </button>
                  <button
                    type="button"
                    onClick={() => router.push(`/activity/${activity.activity_id}`)}
                    className="px-3 py-1 text-white bg-green-500 rounded-md hover:bg-green-600">
                    Edit
                  </button>
                  <button
                    type="button"
                    className="px-3 py-1 text-white bg-blue-500 rounded-md hover:bg-blue-600">
                    Archive
                  </button>
                  <button
                    type="button"
                    className="px-3 py-1 text-white bg-red-500 rounded-md hover:bg-red-600"
                    onClick={() => deleteActivity(activity.activity_id)}>
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

export default ActivityList;
