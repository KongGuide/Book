package com.example.websocketdemo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.web.socket.config.annotation.*;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {

         //应用请求前缀app
        registry.setApplicationDestinationPrefixes("/app");

        // 自定义调度器，用于控制心跳线程
        ThreadPoolTaskScheduler taskScheduler = new ThreadPoolTaskScheduler();
        // 线程池线程数，心跳连接开线程
        taskScheduler.setPoolSize(1);
        // 线程名前缀
        taskScheduler.setThreadNamePrefix("websocket-heartbeat-thread-");
        // 初始化
        taskScheduler.initialize();

         /*简单的本地in-memory broker
         1. 配置内置消息代理broker，推送消息前缀可以配置多个，这里设置/topic
           消息的发送的地址符合配置的前缀来的消息才发送到这个broker
         2. 心跳设置，参数1表示服务器最小能保证发的心跳间隔毫秒数,参数2 server希望client发的心跳间隔毫秒数
         3. 心跳线程调度器 setHeartbeatValue
         */
        registry.enableSimpleBroker("/topic")
                .setHeartbeatValue(new long[]{10000,10000})
                .setTaskScheduler(taskScheduler);

        /*
          外部代理域broker服务，如rabbitmq或activemq
         1. 配置外部消息代理，可以配置多个，这里设置 /topic
         2. setRelayHost 配置代理监听的host,默认为localhost
         3. setRelayPort 配置代理监听的端口，默认为61613
         4. setClientLogin 和 setClientPasscode 配置账号和密码

        registry.enableStompBrokerRelay("/topic")
                .setRelayHost("localhost")
                .setRelayPort(61613)
                .setClientLogin("guest")
                .setClientPasscode("guest");
         */
    }
}
