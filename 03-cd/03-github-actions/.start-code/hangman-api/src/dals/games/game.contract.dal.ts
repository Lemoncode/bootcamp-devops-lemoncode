import { GameEntity } from '../entities';

export  interface GameDAL {
    getGames(playerId: number): Promise<GameEntity[]>;
    addGame(game: GameEntity): Promise<GameEntity>;
}

export type GameDALFactory = (...args: any[]) => GameDAL;
