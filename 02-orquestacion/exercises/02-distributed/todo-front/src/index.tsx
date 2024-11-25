import React from 'react';
import { createRoot } from 'react-dom/client';
import 'regenerator-runtime';
import { TodoContainer } from './components/todo.container';

const container = document.getElementById('root');
const root = createRoot(container!);
root.render(<TodoContainer />);
