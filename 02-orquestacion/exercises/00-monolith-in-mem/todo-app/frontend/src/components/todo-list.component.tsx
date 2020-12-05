import React from 'react';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import Checkbox from '@material-ui/core/Checkbox';
import IconButton from '@material-ui/core/IconButton';
import Delete from '@material-ui/icons/Delete';

export interface Todo {
  id: number;
  title: string;
  completed: boolean;
}

interface Props {
  todos: Todo[];
  toggleCompleted: (id: number) => void;
  onDeleted: (id: number) => void;
}

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      maxWidth: 400,
    },
  }),
);

export const TodoListComponent: React.FC<Props> = (props: Props) => {
  const classes = useStyles();
  const { todos, toggleCompleted, onDeleted } = props;

  const handleSelected = (id: number) => () => toggleCompleted(id);
  const handleDeleted = (id: number) => () => onDeleted(id);

  return (
    <List style={{ margin: 'auto' }} className={classes.root}>
        {todos.length > 0 &&
          todos.map((t) => {
            return (
              <ListItem key={t.id}>
                <ListItemIcon>
                  <Checkbox checked={t.completed} onClick={handleSelected(t.id)} />
                </ListItemIcon>
                <ListItemText primary={t.title} />
                <ListItemSecondaryAction onClick={handleDeleted(t.id)}>
                  <IconButton>
                    <Delete />
                  </IconButton>
                </ListItemSecondaryAction>
              </ListItem>
            );
          })}
      </List>
  );
};
