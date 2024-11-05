# Build Image
FROM node:20.15.0 AS build
WORKDIR /app
COPY . .

RUN <<EOF bash -ex
npm install
npm run build
rm -rf node_modules/.cache
EOF


# Product Image
FROM public.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-nginx:latest-al23

USER root
RUN <<EOF bash -ex
mkdir -p /var/log/nginx
chown -R nginx:nginx /var/log/nginx
touch /run/nginx.pid
chown -R nginx:nginx /run/nginx.pid
EOF

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080
USER nginx
CMD ["nginx", "-g", "daemon off;"]
