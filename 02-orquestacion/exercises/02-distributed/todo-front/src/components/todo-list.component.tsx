import React from 'react';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Checkbox from '@mui/material/Checkbox';
import IconButton from '@mui/material/IconButton';
import Delete from '@mui/icons-material/Delete';

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

export const TodoListComponent: React.FC<Props> = (props: Props) => {
  const { todos, toggleCompleted, onDeleted } = props;

  const handleSelected = (id: number) => () => toggleCompleted(id);
  const handleDeleted = (id: number) => () => onDeleted(id);

  return (
    <List style={{ margin: 'auto' }} sx={{ maxWidth: 400 }}>
      {todos.length > 0 &&
        todos.map((t) => {
          return (
            <ListItem
              key={t.id}
              secondaryAction={
                <IconButton onClick={handleDeleted(t.id)}>
                  <Delete />
                </IconButton>
              }
            >
              <ListItemIcon>
                <Checkbox checked={t.completed} onClick={handleSelected(t.id)} />
              </ListItemIcon>
              <ListItemText primary={t.title} />
            </ListItem>
          );
        })}
    </List>
  );
};
