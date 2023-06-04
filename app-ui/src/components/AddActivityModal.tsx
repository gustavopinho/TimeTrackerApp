import React, { useState } from 'react';
import { Modal, TextField, Button, Box, Typography } from '@mui/material';

interface AddActivityModalProps {
  open: boolean;
  onClose: () => void;
  onAddActivity: (name: string, original_estimate: number) => void;
}

const AddActivityModal: React.FC<AddActivityModalProps> = ({
  open,
  onClose,
  onAddActivity,
}) => {
  const [newActivityName, setNewActivityName] = useState('');
  const [newActivityEstimate, setNewActivityEstimate] = useState<number | ''>('');

  const handleNewActivityNameChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setNewActivityName(event.target.value);
  };

  const handleNewActivityEstimateChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = +event.target.value;
    setNewActivityEstimate(isNaN(value) ? '' : value);
  };

  const handleAddActivity = () => {
    onAddActivity(newActivityName, Number(newActivityEstimate));
    setNewActivityName('');
    setNewActivityEstimate('');
  };

  const handleClose = () => {
    onClose();
    setNewActivityName('');
    setNewActivityEstimate('');
  };

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
          Add Activity
        </Typography>
        <TextField
          label="Activity Name"
          value={newActivityName}
          onChange={handleNewActivityNameChange}
          variant="outlined"
          fullWidth
          margin="normal"
        />
        <TextField
          label="Original Estimate"
          type="number"
          value={newActivityEstimate}
          onChange={handleNewActivityEstimateChange}
          variant="outlined"
          fullWidth
          margin="normal"
        />
        <Button variant="contained" color="primary" onClick={handleAddActivity}>
          Add
        </Button>
        <Button variant="outlined" color="secondary" onClick={handleClose}>
          Close
        </Button>
      </Box>
    </Modal>
  );
};

export default AddActivityModal;
