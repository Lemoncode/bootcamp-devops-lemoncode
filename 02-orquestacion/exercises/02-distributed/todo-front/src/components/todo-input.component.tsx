import React from 'react';
import TextField from '@mui/material/TextField';
import IconButton from '@mui/material/IconButton';
import Add from '@mui/icons-material/Add';

interface Props {
  onAddTodo: (todo: string) => void;
}

export const TodoInputComponent: React.FC<Props> = (props) => {
  const { onAddTodo } = props;
  const [input, setInput] = React.useState('');

  const handleAddTodo = () => {
    if (input) {
      onAddTodo(input);
      setInput('');
    }
  };

  return (
    <div>
      <TextField
        onChange={(evt) => setInput(evt.target.value)}
        value={input}
        variant="outlined"
        helperText="Add todo"
      />
      <IconButton sx={{ marginLeft: 2 }} onClick={handleAddTodo}>
        <Add fontSize="large" />
      </IconButton>
    </div>
  );
};
