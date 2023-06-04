import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Button, Table, TableBody, TableCell, TableHead, TableRow } from '@mui/material';

interface Task {
  task_id: number;
  activity_id: number;
  name: string;
  start_time: string;
  end_time: string;
  duration: number;
}

interface TimeEntry {
  time_entry_id?: number;
  task_id: number;
  start_time: string;
  end_time: string;
}

const TaskTimeEntries: React.FC<{ task: Task }> = ({ task }) => {
  const [timeEntries, setTimeEntries] = useState<TimeEntry[]>([]);
  const [playing, setPlaying] = useState(false);
  const [playingTimeEntry, setPlayingTimeEntry] = useState<TimeEntry | null>(null);
  const [elapsedMinutes, setElapsedMinutes] = useState(0);

  useEffect(() => {
    fetchTimeEntries();
    fetchTimeEntriesWithoutEndTime();
  }, [task]);

  useEffect(() => {
    let interval: NodeJS.Timeout;

    if (playing) {
      interval = setInterval(() => {
        setElapsedMinutes((prevElapsedMinutes) => prevElapsedMinutes + 1);
      }, 60000);
    }

    return () => clearInterval(interval);
  }, [playing]);

  const fetchTimeEntries = async () => {
    try {
      const response = await axios.get(`/api/time_entries/task/${task.task_id}/`);
      setTimeEntries(response.data);
    } catch (error) {
      console.error('Failed to fetch time entries:', error);
    }
  };

  const fetchTimeEntriesWithoutEndTime = async () => {
    try {
      const response = await axios.get(`/api/time_entries/task/${task.task_id}/playing`);
      setPlayingTimeEntry(response.data);
      setPlaying(true);
      setElapsedMinutes(calculateElapsedMinutes(response.data.start_time));
    } catch (error) {
      console.error('Failed to fetch time entries:', error);
    }
  };

  const addTimeEntry = async () => {
    try {
      const response = await axios.post(`/api/time_entries/${task.task_id}/start`);
      setPlayingTimeEntry(response.data);
      fetchTimeEntries();
    } catch (error) {
      console.error('Failed to add time entry:', error);
    }
  };

  const updateTimeEntry = async (timeEntryId: number | undefined) => {
    try {
      await axios.put(`/api/time_entries/${timeEntryId}/stop`);
      fetchTimeEntries();
    } catch (error) {
      console.error('Failed to update time entry:', error);
    }
  };

  const handlePlayButtonClick = async () => {
    if (playing) {
      // Stop the current time entry
      if (playingTimeEntry && !playingTimeEntry.end_time) {
        await updateTimeEntry(playingTimeEntry.time_entry_id);
      }
    } else {
      // Start a new time entry
      await addTimeEntry();
    }

    // Toggle the playing state
    setPlaying(!playing);
    setElapsedMinutes(0);
  };

  const calculateElapsedMinutes = (startTime: string): number => {
    const currentTime = new Date();
    const timeDifference = currentTime.getTime() - new Date(startTime).getTime();
    const elapsedMinutes = Math.floor(timeDifference / (1000 * 60));
    return elapsedMinutes;
  };

  const renderPlayButton = () => {
    if (playing) {
      return (
        <Button variant="contained" color="secondary" onClick={handlePlayButtonClick}>
          Stop
        </Button>
      );
    } else {
      return (
        <Button variant="contained" color="primary" onClick={handlePlayButtonClick}>
          Start
        </Button>
      );
    }
  };

  return (
    <div>
      {renderPlayButton()}
      <div>Elapsed Minutes: {elapsedMinutes}</div>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Start Time</TableCell>
            <TableCell>End Time</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {timeEntries.map((timeEntry) => (
            <TableRow key={timeEntry.time_entry_id}>
              <TableCell>{timeEntry.start_time}</TableCell>
              <TableCell>{timeEntry.end_time}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
};

export default TaskTimeEntries;