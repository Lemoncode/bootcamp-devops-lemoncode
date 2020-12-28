# csk8s-cli hello world

> Open a remote container to avoid install globally the package.
> Reference: https://cdk8s.io/docs/v1.0.0-beta.5/getting-started/

## Install the package

```bash
$ npm i -g cdk8s-cli
```

## Create a new project

```bash
$ mkdir hello
$ cd hello
$ cdk8s init typescript-app
```

By running the above commands we are doing the following:

1. Create a new project
2. Install CDK8s as a depenedncy
3. Import all Kubernetes API objects

The output must be something similar to this

```bash
$ cdk8s init typescript-app
Initializing a project from the typescript-app template
npm notice created a lockfile as package-lock.json. You should commit this file.
+ constructs@3.2.78
+ cdk8s@1.0.0-beta.5
+ cdk8s-plus-17@1.0.0-beta.5
added 12 packages from 10 contributors and audited 12 packages in 3.542s

# .....

+ cdk8s-cli@1.0.0-beta.5
+ jest@26.6.3
+ ts-jest@26.4.4
+ @types/jest@26.0.19
+ @types/node@14.14.14
+ typescript@4.1.3
added 629 packages from 437 contributors and audited 644 packages in 29.751s

62 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities


> hello@1.0.0 import /workspaces/bootcamp-devops-lemoncode/04-cloud/01-eks/08-ckd8s/00-hello-world-code/hello
> cdk8s import

k8s

> hello@1.0.0 compile /workspaces/bootcamp-devops-lemoncode/04-cloud/01-eks/08-ckd8s/00-hello-world-code/hello
> tsc


> hello@1.0.0 test /workspaces/bootcamp-devops-lemoncode/04-cloud/01-eks/08-ckd8s/00-hello-world-code/hello
> jest "-u"

 PASS  ./main.test.ts
  Placeholder
    ✓ Empty (3 ms)

 › 1 snapshot written.
Snapshot Summary
 › 1 snapshot written from 1 test suite.

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
Snapshots:   1 written, 1 total
Time:        2.52 s
Ran all test suites.

> hello@1.0.0 synth /workspaces/bootcamp-devops-lemoncode/04-cloud/01-eks/08-ckd8s/00-hello-world-code/hello
> cdk8s synth

dist/hello.k8s.yaml
========================================================================================================

 Your cdk8s typescript project is ready!

   cat help         Print this message
 
  Compile:
   npm run compile     Compile typescript code to javascript (or "yarn watch")
   npm run watch       Watch for changes and compile typescript in the background
   npm run build       Compile + synth

  Synthesize:
   npm run synth       Synthesize k8s manifests from charts to dist/ (ready for 'kubectl apply -f')

 Deploy:
   kubectl apply -f dist/*.k8s.yaml

 Upgrades:
   npm run import        Import/update k8s apis (you should check-in this directory)
   npm run upgrade       Upgrade cdk8s modules to latest version
   npm run upgrade:next  Upgrade cdk8s modules to latest "@next" version (last commit)

========================================================================================================
``` 

## Apps and Charts

Apps are structured as a tree of **constructs**, which are composable units of abstraction.

Initilizes completely the project for us.

This initial code created by cdk8s `init` defines an app with a single, empty, chart.

When you run `cdk8s synth`, a Kubernetes manifest YAML will be synthesized for each Chart in your app and will write it to the dist directory.

## Importing Constructs for the Kubernetes API

Let's define some Kubernetes API objects inside our chart.

Similarly to **charts** and **apps**, Kubernetes API Objects are also represented in CDK8s as constructs. These constructs are imported to your project using the `cdk8s import` command which will add source files to your project that include constructs that represent the Kubernetes API.

> NOTE: When cdk8s init created your project it already executed cdk8s import for you, so you should see an imports directory already there. You can either commit this directory to source-control or generate it as part of your build process.

Let's define a simple Kubernetes application, that includes a Deployment and a Service

```ts
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

``` 

Now, compile & synth this poject:

```bash
$ cdk8s synth
```