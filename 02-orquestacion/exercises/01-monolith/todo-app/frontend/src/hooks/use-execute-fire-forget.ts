import { useState, useCallback } from 'react';

export const useExecuteFireForget = () => {
  const [error, setError] = useState(null);

  const execute = async (callback, ...args) => {
    try {
        return await callback(...args);
    } catch (error) {
      setError(error);
    }
  };

  return [error, { execute: useCallback(execute, []) }];
};
