import React from 'react';
import { render, screen } from '@testing-library/react';
import { StartGameComponent } from './start-game.component';
import * as api from '../services/game.api';

describe('StartGame component specs', () => {
  it('should display a list of topics', async () => {
    const getTopicsStub = jest
      .spyOn(api, 'getTopics')
      .mockResolvedValue(['topic A', 'topic B']);
    
    render(<StartGameComponent />);

    const items = await screen.findAllByRole('listitem');

    expect(items).toHaveLength(1);
    expect(getTopicsStub).toHaveBeenCalled();
  });
});
