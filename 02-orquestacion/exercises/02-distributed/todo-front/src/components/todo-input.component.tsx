import React from 'react';
import { createStyles, Theme, makeStyles } from '@material-ui/core/styles';
import TextField from '@material-ui/core/TextField';
import IconButton from '@material-ui/core/IconButton';
import Add from '@material-ui/icons/Add';

interface Props {
  onAddTodo: (todo: string) => void;
};

const useStyles = makeStyles((theme: Theme) => createStyles({
  margin: {
    marginLeft: theme.spacing(2),
  },
}));

export const TodoInputComponent: React.FC<Props> = (props) => {
  const classes = useStyles();
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
      <IconButton className={classes.margin} onClick={handleAddTodo}>
        <Add fontSize="large" />
      </IconButton>
    </div>
  );
};
