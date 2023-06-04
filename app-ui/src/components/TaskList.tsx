import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
  Container,
  Typography,
  Table,
  TableHead,
  TableBody,
  TableRow,
  TableCell,
  Button,
  Modal,
  TextField,
  Box,
  TableContainer,
} from '@mui/material';
import TaskTimeEntries from './TaskTimeEntries';

interface Task {
  task_id: number;
  activity_id: number;
  name: string;
  start_time: string;
  end_time: string;
  duration: number;
}

interface Activity {
  activity_id?: number;
  name: string;
  original_estimate: number;
  remaining_hours: number;
  completed_hours: number;
}

interface TaskListProps {
  activity: Activity;
}

const TaskList: React.FC<TaskListProps> = ({ activity }) => {

  const [tasks, setTasks] = useState<Task[]>([]);
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);
  const [openModal, setOpenModal] = useState(false);
  const [newTaskName, setNewTaskName] = useState('');

  useEffect(() => {
    fetchTasks();
  }, [activity]);

  const fetchTasks = async () => {
    try {
      const response = await axios.get(`/api/tasks/activity/${activity.activity_id}/`);
      setTasks(response.data);
    } catch (error) {
      console.error('Failed to fetch tasks:', error);
    }
  };

  const addTask = async () => {
    const taskData = {
      activity_id: activity.activity_id,
      name: newTaskName,
      start_time: null,
      end_time: null,
    };

    try {
      const response = await axios.post('/api/tasks/', taskData);
      const newTask = response.data;
      setTasks([...tasks, newTask]);
      setNewTaskName('');
      setOpenModal(false);
    } catch (error) {
      console.error('Failed to add task:', error);
    }
  };

  const removeTask = async (taskId: number) => {
    try {
      await axios.delete(`/api/tasks/${taskId}/`);
      setTasks(tasks.filter((task) => task.task_id !== taskId));
      setSelectedTask(null);
    } catch (error) {
      console.error('Failed to remove task:', error);
    }
  };

  const selectTask = (task: Task) => {
    setSelectedTask(task);
  };

  const handleOpenModal = () => {
    setOpenModal(true);
  };

  const handleCloseModal = () => {
    setOpenModal(false);
    setNewTaskName('');
  };

  const handleNewTaskNameChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setNewTaskName(event.target.value);
  };

  return (
    <>
      <Typography variant="h4" component="h1" gutterBottom>
        Task List for Activity: {activity.name}
      </Typography>
      <Button variant="contained" color="primary" onClick={handleOpenModal}>
        Add Task
      </Button>
      <TableContainer style={{ maxHeight: 300 }}>
        <Table stickyHeader size="small" aria-label="task table" sx={{ border: '1px solid rgba(0, 0, 0, 0.12)' }}>
          <TableHead>
            <TableRow>
              <TableCell>Task ID</TableCell>
              <TableCell>Name</TableCell>
              <TableCell>Start Time</TableCell>
              <TableCell>End Time</TableCell>
              <TableCell>Duration</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {tasks.map((task) => (
              <TableRow key={task.task_id} selected={selectedTask?.task_id === task.task_id} onClick={() => selectTask(task)}>
                <TableCell>{task.task_id}</TableCell>
                <TableCell>{task.name}</TableCell>
                <TableCell>{task.start_time}</TableCell>
                <TableCell>{task.end_time}</TableCell>
                <TableCell>{task.duration}</TableCell>
                <TableCell>
                  <Button
                    variant="outlined"
                    size="small"
                    color="secondary"
                    onClick={() => removeTask(task.task_id)}
                  >
                    Remove
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
      
      {selectedTask && (
        <TaskTimeEntries task={selectedTask} />
      )}

      <Modal open={openModal} onClose={handleCloseModal}>
        <Box
          sx={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            bgcolor: 'background.paper',
            boxShadow: 24,
            p: 4,
            minWidth: 300,
          }}
        >
          <Typography variant="h5" component="h2" gutterBottom>
            Add Task
          </Typography>
          <TextField
            label="Task Name"
            value={newTaskName}
            onChange={handleNewTaskNameChange}
            variant="outlined"
            fullWidth
            margin="normal"
          />
          <Button variant="contained" color="primary" onClick={addTask}>
            Add
          </Button>
          <Button variant="outlined" color="secondary" onClick={handleCloseModal}>
            Close
          </Button>
        </Box>
      </Modal>
    </>
  );
};

export default TaskList;