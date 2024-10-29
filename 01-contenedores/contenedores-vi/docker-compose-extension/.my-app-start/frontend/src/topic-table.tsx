import React from "react";
import { Topic } from "./model";
import { TopicRow } from "./topic-row";

export const TopicTable = () => {
  const [topics, setTopics] = React.useState<Topic[]>([]);

  React.useEffect(() => {
    fetch("http://localhost:8080/api/topics")
      .then((response) => response.json())
      .then((result) => setTopics(result));
  }, []);

  return (
    <table>
      <thead>
        <th>
          <span className="header">Id</span>
        </th>
        <th>
          <span className="header">Name</span>
        </th>
      </thead>

      <tbody>
        {topics.map((topic) => (
          <TopicRow topic={topic} />
        ))}
      </tbody>
    </table>
  );
};
