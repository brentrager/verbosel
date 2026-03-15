/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
    app(input) {
        return {
            name: "verbosel",
            removal: input?.stage === "production" ? "retain" : "remove",
            home: "aws",
            providers: {
                aws: {
                    region: "us-east-2",
                },
                cloudflare: true,
            },
        };
    },
    async run() {
        const vpc = new sst.aws.Vpc("Vpc", { nat: "ec2" });
        const cluster = new sst.aws.Cluster("Cluster", { vpc });

        const server = new sst.aws.Service("AsmServer", {
            cluster,
            image: {
                context: "./server",
                dockerfile: "Dockerfile",
                args: { CACHE_BUST: Date.now().toString() },
            },
            cpu: "0.25 vCPU",
            memory: "0.5 GB",
            loadBalancer: {
                rules: [
                    { listen: "80/http", redirect: "443/https" },
                    { listen: "443/https", forward: "8080/http" },
                ],
                domain: {
                    name: "verbosel.rager.tech",
                    dns: sst.cloudflare.dns(),
                },
            },
        });

        return {
            url: server.url,
        };
    },
});
