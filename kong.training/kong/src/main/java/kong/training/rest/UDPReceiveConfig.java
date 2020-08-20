package kong.training.rest;


import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.integration.annotation.Filter;
import org.springframework.integration.annotation.Router;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.annotation.Transformer;
import org.springframework.integration.ip.udp.UnicastReceivingChannelAdapter;
import org.springframework.messaging.Message;

@EnableAutoConfiguration
public class UDPReceiveConfig {


    @Bean
    public UnicastReceivingChannelAdapter getUnicastReceivingChannelAdapter() {
        UnicastReceivingChannelAdapter adapter = new  UnicastReceivingChannelAdapter(4567);
        adapter.setOutputChannelName("udp");
        return adapter;
    }

    @Transformer(inputChannel="udp",outputChannel="udpString")
    public String transformer(Message<?> message) {
        //把接收的数据转化为字符串
        return new String((byte[])message.getPayload());
    }

    @Filter(inputChannel="udpString",outputChannel="udpFilter")
    public boolean filter(String message) {
        //System.out.println("filter:" + message);
        //只处理包含有kong，反之不处理直接过滤掉
        //返回true处理，返回false不处理
        return message.contains("kong");
    }

    @Router(inputChannel="udpFilter")
    public String routing(String message) {
        //当接收数据包含kong时
        if(message.contains("kong")) {
            return "KongUDPRoute";
        }
        else {
            return "OtherUDPRoute";
        }
    }


    @ServiceActivator(inputChannel="KongUDPRoute")
    public void udpMessageHandle(String message) {
        System.out.println("kong udp:" +message);
    }


    @ServiceActivator(inputChannel="OtherUDPRoute")
    public void udpMessageHandle2(String message) {
        System.out.println("other udp:" +message);
    }


}
