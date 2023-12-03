import { PlayerEntity, Player } from '../entities';

export interface PlayerDAL {
    addPlayer(player: Player): Promise<PlayerEntity>;
}

export type PlayerDALFactory = (...args: any[]) => PlayerDAL;
