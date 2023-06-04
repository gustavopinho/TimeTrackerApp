import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
  Container,
  Typography,
  Table,
  TableContainer,
  TableHead,
  TableBody,
  TableRow,
  TableCell,
  Button,
  Snackbar,
  Box
} from '@mui/material';

import AddActivityModal from './AddActivityModal';
import UpdateActivityModal from './UpdateActivityModal';

interface Activity {
  activity_id?: number;
  name: string;
  original_estimate: number;
  remaining_hours: number;
  completed_hours: number;
}

const ActivityList: React.FC = () => {
  const [activities, setActivities] = useState<Activity[]>([]);
  const [selectedActivity, setSelectedActivity] = useState<Activity | null>(null);
  const [activityToUpdate, setActivityToUpdate] = useState<Activity | null>(null);

  // Message 
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState<'success' | 'error' | 'warning' | 'info'>('success');

  // Add activity
  const [openModalActivity, setOpenModalActivity] = useState(false);

  // Update activity
  const [openUpdateModalActivity, setOpenUpdateModalActivity] = useState(false);

  useEffect(() => {
    fetchActivities();
  }, []);

  const showMessage = (message: string, type: 'success' | 'error' | 'warning' | 'info') => {
    setMessage(message);
    setMessageType(type);
  };

  const handleCloseMessage = () => {
    setMessage('');
  };

  const fetchActivities = async () => {
    try {
      const response = await axios.get('/api/activities/');
      setActivities(response.data);
    } catch (error) {
      console.error('Failed to fetch activities:', error);
    }
  };

  const addActivity = async (name: string, original_estimate: number) => {
    const activityData = {
      name: name,
      original_estimate: original_estimate,
    };

    try {
      const response = await axios.post('/api/activities/', activityData);
      const newActivity = response.data;
      setActivities([...activities, newActivity]);
      showMessage('Activity added successfully!', 'success');
    } catch (error) {
      console.error('Failed to add activity:', error);
      showMessage('Failed to add activity.', 'error');
    }
  };

  const removeActivity = async (activityId: number | undefined) => {
    try {
      await axios.delete(`/api/activities/${activityId}/`);
      setActivities(activities.filter((activity) => activity.activity_id !== activityId));
      setSelectedActivity(null);
      showMessage('Activity removed successfully!', 'success');
    } catch (error) {
      console.error('Failed to remove activity:', error);
      showMessage('Failed to remove activity.', 'error');
    }
  };

  const handleUpdateActivity = async (name: string, original_estimate: number, remaining_hours: number, completed_hours: number) => {
    console.log(name, original_estimate, remaining_hours, completed_hours)
    if (activityToUpdate) {
      const updatedActivity = {
        ...activityToUpdate,
        name,
        original_estimate,
        remaining_hours,
        completed_hours,
      };

      console.log(updatedActivity)

      try {
        await axios.put(`/api/activities/${activityToUpdate.activity_id}/`, updatedActivity);

        fetchActivities();

        handleCloseModalUpdateActivity();
        showMessage('Activity updated successfully!', 'success');
      } catch (error) {
        console.error('Failed to update activity:', error);
        showMessage('Failed to update activity.', 'error');
      }
    }
  };

  const selectActivity = (activity: Activity) => {
    setSelectedActivity(activity);
  };

  const handleOpenModalActivity = () => {
    setOpenModalActivity(true);
  };

  const handleCloseModalActivity = () => {
    setOpenModalActivity(false);
  };

  const handleOpenModalUpdateActivity = (activity: Activity) => {
    setActivityToUpdate(activity)
    setOpenUpdateModalActivity(true);
  };

  const handleCloseModalUpdateActivity = () => {
    setOpenUpdateModalActivity(false);
  };

  return (
    <Container>
      <Typography variant="h4" component="h1" gutterBottom>
        Activity List
      </Typography>
      <Button variant="contained" color="primary" size="small" onClick={handleOpenModalActivity}>
        Add Activity
      </Button>
      <TableContainer style={{ maxHeight: 300 }}>
        <Table stickyHeader size="small" aria-label="activity table" sx={{ border: '1px solid rgba(0, 0, 0, 0.12)' }}>
          <TableHead>
            <TableRow>
              <TableCell>Activity ID</TableCell>
              <TableCell>Name</TableCell>
              <TableCell>Original Estimate</TableCell>
              <TableCell>Remaining Hours</TableCell>
              <TableCell>Completed Hours</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {activities.map((activity) => (
              <TableRow
                key={activity.activity_id}
                selected={selectedActivity?.activity_id === activity.activity_id}
                onClick={() => selectActivity(activity)}
              >
                <TableCell>{activity.activity_id}</TableCell>
                <TableCell>{activity.name}</TableCell>
                <TableCell>{activity.original_estimate}</TableCell>
                <TableCell>{activity.remaining_hours}</TableCell>
                <TableCell>{activity.completed_hours}</TableCell>
                <TableCell>
                  <Button
                    variant="outlined"
                    color="primary"
                    size="small"
                    onClick={() => handleOpenModalUpdateActivity(activity)}
                  >
                    Update
                  </Button>
                  <Button
                    variant="outlined"
                    size="small"
                    color="secondary"
                    onClick={() => removeActivity(activity.activity_id)}
                  >
                    Remove
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
      {selectedActivity && (
        <Typography variant="h6" component="h2" gutterBottom>
          Selected Activity: {selectedActivity.name}
        </Typography>
      )}

      <AddActivityModal
        open={openModalActivity}
        onClose={handleCloseModalActivity}
        onAddActivity={addActivity}
      />

      <UpdateActivityModal
        open={openUpdateModalActivity}
        onClose={handleCloseModalUpdateActivity}
        onUpdateActivity={handleUpdateActivity}
        activity={activityToUpdate}
      />

      <Snackbar open={!!message} autoHideDuration={3000} onClose={handleCloseMessage}>
        <Box
          sx={{
            width: '100%',
            maxWidth: 400,
            bgcolor: messageType === 'success' ? 'success.main' :
              messageType === 'error' ? 'error.main' :
                messageType === 'warning' ? 'warning.main' :
                  messageType === 'info' ? 'info.main' : '',
            color: messageType === 'success' ? 'success.contrastText' :
              messageType === 'error' ? 'error.contrastText' :
                messageType === 'warning' ? 'warning.contrastText' :
                  messageType === 'info' ? 'info.contrastText' : '',
            p: 2,
            borderRadius: 4,
          }}
        >
          <Typography variant="body1">{message}</Typography>
        </Box>
      </Snackbar>

    </Container>
  );
};

export default ActivityList;
