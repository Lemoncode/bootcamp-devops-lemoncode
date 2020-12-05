import React from 'react';
import Snackbar from '@material-ui/core/Snackbar';
import MuiAlert, { AlertProps, Color } from '@material-ui/lab/Alert';

function Alert(props: AlertProps) {
  return <MuiAlert elevation={6} variant="filled" {...props} />;
}

interface Props {
    message: string;
    severity: Color;
    open: boolean;
    duration?: number;
    handleClose?: (event?: React.SyntheticEvent, reason?: string) => void;
}

export const MessageComponent: React.FC<Props> = ({message, severity, open, duration, handleClose}) => (
  <Snackbar open={open} autoHideDuration={duration} onClose={handleClose}>
    <Alert severity={severity}  onClose={handleClose}>{message}</Alert>
  </Snackbar>
);
