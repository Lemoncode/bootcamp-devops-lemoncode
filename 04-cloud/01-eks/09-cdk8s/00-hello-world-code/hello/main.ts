import { Construct } from 'constructs';
import { App, Chart, ChartProps } from 'cdk8s';

import { KubeDeployment, KubeService, IntOrString } from './imports/k8s';

export class MyChart extends Chart {
  constructor(scope: Construct, id: string, props: ChartProps = {}) {
    super(scope, id, props);

    const label = { app: 'hello-k8s' };

    new KubeService(this, 'service', {
      spec: {
        type: 'LoadBalancer',
        ports: [{ port: 80, targetPort: IntOrString.fromNumber(8080) }]
      }
    });

    new KubeDeployment(this, 'deployment', {
      spec: {
        replicas: 2,
        selector: {
          matchLabels: label
        },
        template: {
          metadata: { labels: label },
          spec: {
            containers: [
              {
                name: 'hello-kubernetes',
                image: 'paulbower/hello-kubernetes:1.7',
                ports: [{ containerPort: 8080 }]
              }
            ]
          }
        }
      }
    });

  }
}

const app = new App();
new MyChart(app, 'hello');
app.synth();
