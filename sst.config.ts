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

        // The Assembly HTTP Server - raw x86_64 syscalls serving HTML
        const asmServer = new sst.aws.Service("AsmServer", {
            cluster,
            image: {
                context: "./server",
                dockerfile: "server/Dockerfile",
            },
            cpu: "0.25 vCPU",
            memory: "0.5 GB",
            loadBalancer: {
                rules: [
                    { listen: "80/http", redirect: "443/https" },
                    { listen: "443/https", forward: "8080/http" },
                ],
                domain: {
                    name: "asm.rager.tech",
                    dns: sst.cloudflare.dns(),
                },
            },
        });

        // The Next.js documentation/landing site
        const site = new sst.aws.Nextjs("Site", {
            path: "site",
            openNextVersion: "3.6.6",
            domain: {
                name: "assembly-wf.rager.tech",
                dns: sst.cloudflare.dns(),
            },
            environment: {
                NEXT_PUBLIC_ASM_SERVER_URL: $interpolate`${asmServer.url}`.apply(
                    (v) => v.replace(/\/+$/, ""),
                ),
            },
        });

        return {
            asmServer: asmServer.url,
            site: site.url,
        };
    },
});
