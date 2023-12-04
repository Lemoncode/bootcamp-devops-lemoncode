import React, { useEffect, useState } from 'react';
import { getTopics } from '../services';

export const StartGameComponent = () => {
  const [topics, setTopics] = useState<string[]>([]);

  useEffect(() => {
    getTopics()
      .then((data) => setTopics(data as string[]))
      .catch(console.error);
  }, []);

  return (
    <>
      <h1>Start Hangman</h1>
      <h2>Please select a topic to start playing</h2>
      <ul>{(topics && topics.length) > 0 && topics.map((t, i) => <li key={i}>{t}</li>)}</ul>
    </>
  );
};
