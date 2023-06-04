import React, { useState } from 'react';
import { Modal, TextField, Button, Box, Typography } from '@mui/material';

interface UpdateActivityModalProps {
  open: boolean;
  onClose: () => void;
  onUpdateActivity: (name: string, original_estimate: number, remaining_hours: number, completed_hours: number) => void;
  activity: {
    name: string;
    original_estimate: number;
    remaining_hours: number;
    completed_hours: number;
  } | null;
}

const UpdateActivityModal: React.FC<UpdateActivityModalProps> = ({
  open,
  onClose,
  onUpdateActivity,
  activity,
}) => {
  const [newActivityName, setNewActivityName] = useState('');
  const [newActivityEstimate, setNewActivityEstimate] = useState<number | ''>('');
  const [newRemainingHours, setNewRemainingHours] = useState<number | ''>('');
  const [newCompletedHours, setNewCompletedHours] = useState<number | ''>('');

  const handleNewActivityNameChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setNewActivityName(event.target.value);
  };

  const handleNewActivityEstimateChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = +event.target.value;
    setNewActivityEstimate(isNaN(value) ? '' : value);
  };

  const handleNewRemainingHoursChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = +event.target.value;
    setNewRemainingHours(isNaN(value) ? '' : value);
  };

  const handleNewCompletedHoursChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = +event.target.value;
    setNewCompletedHours(isNaN(value) ? '' : value);
  };

  const handleUpdateActivity = () => {
    onUpdateActivity(
      newActivityName,
      Number(newActivityEstimate),
      Number(newRemainingHours),
      Number(newCompletedHours)
    );
    setNewActivityName('');
    setNewActivityEstimate('');
    setNewRemainingHours('');
    setNewCompletedHours('');
  };

  const handleClose = () => {
    onClose();
    setNewActivityName('');
    setNewActivityEstimate('');
    setNewRemainingHours('');
    setNewCompletedHours('');
  };

  if (!activity) return null;

  return (
    <Modal open={open} onClose={handleClose}>
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
          Update Activity
        </Typography>
        <TextField
          label="Activity Name"
          value={newActivityName || activity.name}
          onChange={handleNewActivityNameChange}
          variant="outlined"
          fullWidth
          margin="normal"
        />
        <TextField
          label="Original Estimate"
          type="number"
          value={newActivityEstimate || activity.original_estimate}
          onChange={handleNewActivityEstimateChange}
          variant="outlined"
          fullWidth
          margin="normal"
        />
        <TextField
          label="Remaining Hours"
          type="number"
          value={newRemainingHours || activity.remaining_hours}
          onChange={handleNewRemainingHoursChange}
          variant="outlined"
          fullWidth
          margin="normal"
        />
        <TextField
          label="Completed Hours"
          type="number"
          value={newCompletedHours || activity.completed_hours}
          onChange={handleNewCompletedHoursChange}
          variant="outlined"
          fullWidth
          margin="normal"
        />
        <Button variant="contained" color="primary" onClick={handleUpdateActivity}>
          Update
        </Button>
        <Button variant="outlined" color="secondary" onClick={handleClose}>
          Close
        </Button>
      </Box>
    </Modal>
  );
};

export default UpdateActivityModal;
