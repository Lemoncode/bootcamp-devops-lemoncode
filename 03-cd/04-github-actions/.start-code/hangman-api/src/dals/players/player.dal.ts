import { Knex } from 'knex';
import { Player, PlayerEntity } from '../entities';
import { PlayerDALFactory } from './player.contract.dal';

export const playerDALFactory: PlayerDALFactory = (knex: Knex) => ({
  async addPlayer(player: Player): Promise<PlayerEntity> {
    const result = await knex<PlayerEntity>('players').insert(
      [{
        ...player,
      }],
      '*',
    );
    const [p] = result;
    return p;
  },
});
