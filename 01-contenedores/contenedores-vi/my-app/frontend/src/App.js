import React, { Component } from 'react';
import { Container, Header, Message, Table } from 'semantic-ui-react';

export default class App extends Component {

  constructor(props) {
    super(props);
    this.state = {
      topics: null,
      isLoading: null
    };
  }

  componentWillMount() {
    this.getTopics();
  }

  async getTopics() {

    try {

      this.setState({ isLoading: true });
      let response = await fetch('http://localhost:8080/api/topics');
      let data = await response.json();

      this.setState({
        topics: data,
        isLoading: false
      });

    } catch (error) {
      this.setState({ isLoading: false });
      console.error(error);
    }

  }

  render() {
    return (
      <Container text style={{ marginTop: '7em' }}>
        <Header as="h1">Topics</Header>
        {this.state.isLoading && <Message info header="Loading topics..." />}
        {this.state.topics && (
          <div>
            <Table>
              <thead>
                <tr>
                  <th>Name</th>
                </tr>
              </thead>
              <tbody>
                {this.state.topics.map(topic => (
                  <tr id={topic._id} key={topic._id}>
                    <td>{topic.name}</td>
                  </tr>
                ))}
              </tbody>
            </Table>
          </div>
        )}
      </Container>
    );
  }
}