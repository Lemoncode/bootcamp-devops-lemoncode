import { useState, useCallback } from 'react';

export const useExecuteAsync = () => {
  const [isRunning, setIsRunning] = useState(false);
  const [error, setError] = useState<null | string>(null);
  const [result, setResult] = useState<null | any[]>(null);

  const execute = async (callback, ...args) => {
    try {
      setIsRunning(true);
      const result = await callback(...args);
      if (result) {
        setResult(result);
        setIsRunning(false);
      }

      return result;
    } catch (error) {
      setError(error);
      setIsRunning(false);
    }
  };

  return [isRunning, error, result, { execute: useCallback(execute, []) }];
};
