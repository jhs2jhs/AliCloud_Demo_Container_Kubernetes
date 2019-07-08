# Intro

ARMS ([Application Realtime Monitoring Service](https://www.alibabacloud.com/product/arms)) is for application level monitoring. It's strong at Java applications and can integrate with ACK ([Alibaba Container Service for Kubernetes](https://www.alibabacloud.com/product/kubernetes)) easily.

# Demo

Use ARMS to monitor PiggyMetrics which deployed on ACK. This process is generic, it can be applied to other applications with same procedure.

## Step 1: enable ARMS

Enable ARMS from web console if you haven't done so.

## Step 2: install ARMS from ACK App Catalog

ACK provides an app catalog for easy tooling installation. Access from [ACK console](https://cs.console.aliyun.com)->Store->App Catalog.

![alt-text](images/step2.app-catalog.png)

The ARMS component can be installed with a single click.

![alt-text](images/step2.deploy.png)

## Step 3: verify the installation

The component then later can be located in the namespace.

![alt-text](images/step3.verify.png)

## Step 4: config RAM role

In order for the cluster to access the ARMS service, we need to add ARMS access to the worker's role.

Go to Clusters->Cluster List and locate your cluster, then click and check the Basic Information:

![alt-text](images/step4.ram-role.png)

Then edit the associated policy:

![alt-text](images/step4.ram-role-policy.png)

Append the following block to the policy statement (and don't forget to add `,` before the block):

```JSON
{
    "Action": "arms:*",
    "Resource": "*",
    "Effect": "Allow"
}
```

![alt-text](images/step4.ram-role-policy-edit.png)

## Step 5: edit the app YAML file

This is the last step. Locate the Java application deployment from Applications->Deployments and click `more` from the Action column, then click `YAML` to edit.

Add the following annotation in `spec`->`template`->`metadata`->`annotations`.

```YAML
annotations:
    armsPilotAutoEnable: 'on'
    armsPilotCreateAppName: 'account-service'
```

![alt-text](images/step5.enable-arms.png)

Then click `Update`.

After the deployment restarted, you will find `ARMS console` appears at the Action column.

![alt-text](images/step5.enabled.png)

Enjoy!

![alt-text](images/step5.ui.png)
