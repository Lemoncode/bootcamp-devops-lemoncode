import { Knex } from 'knex';
import { GameDALFactory } from './game.contract.dal';
import { GameEntity } from '../entities';

export const gameDALFactory: GameDALFactory = (knex: Knex) => ({
  async getGames(playerId: number): Promise<GameEntity[]> {
    return knex<GameEntity>('games').where('player_id', playerId);
  },
  async addGame(game: GameEntity): Promise<GameEntity> {
    const result = await knex<GameEntity>('games').insert(
      [{
        ...game,
      }],
      '*',
    );
    const [g] = result;
    return g;
  },
});
