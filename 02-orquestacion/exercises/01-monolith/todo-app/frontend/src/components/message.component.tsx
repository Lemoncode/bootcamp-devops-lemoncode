import React from 'react';
import Snackbar from '@mui/material/Snackbar';
import Alert, { AlertColor } from '@mui/material/Alert';

interface Props {
  message: string;
  severity: AlertColor;
  open: boolean;
  duration?: number;
  handleClose?: (event?: React.SyntheticEvent | Event, reason?: string) => void;
}

export const MessageComponent: React.FC<Props> = ({ message, severity, open, duration, handleClose }) => (
  <Snackbar open={open} autoHideDuration={duration} onClose={handleClose}>
    <Alert severity={severity} onClose={handleClose}>
      {message}
    </Alert>
  </Snackbar>
);
