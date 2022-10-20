import { ObjectId } from 'mongodb';
import { Topic as TopicEntity } from '../entities';
import { TopicDatabase} from '../dal/topics.contract.dal';

function isTopicDatabase(topic: TopicEntity | TopicDatabase): topic is TopicDatabase {
    if((topic as TopicDatabase)._id) {
        return true;
    }
    return false;
} 

function isTopicEntity(topic: TopicEntity | TopicDatabase): topic is TopicEntity {
    if((topic as TopicEntity).id) {
        return true;
    }
    return false;
} 

export function mapTopic(topic: TopicEntity | TopicDatabase): TopicEntity | TopicDatabase {
    if (isTopicDatabase(topic)) {
        return {
            ...topic,
            id: topic._id.toString(),
        }
    }

    if(isTopicEntity(topic)) {
        return {
            ...topic,
            _id: new ObjectId(topic.id),  
        }
    }
}

export function mapTopics(topics: TopicEntity[] | TopicDatabase[]): TopicEntity[] | TopicDatabase[] {
    return topics.map(mapTopic);
}
