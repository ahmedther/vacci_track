# Use the Alpine Linux base image
FROM postgres:alpine3.19 as builder

# Set the timezone to IST (Indian Standard Time)
ENV TZ=Asia/Kolkata

# Update the package repository and install the timezone data package
RUN apk update && \
    apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apk del tzdata && \
    rm -rf /var/cache/apk/* /root/.cache 


# Create a new stage for the final image
FROM postgres:alpine3.18

# Copy the timezone configuration from the builder stage
COPY --from=builder /etc/localtime /etc/localtime
