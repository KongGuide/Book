package kong.training.rest;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;

@RestController
@EnableAutoConfiguration
@RequestMapping("health")
public class HealthController {

    //******
    //http://localhost:8000/health/node
    //获取当前服务器节点IP
    @RequestMapping(value = "node", produces = { "application/json" })
    public String getNode() {
        try {
            InetAddress address = InetAddress.getLocalHost();
            return address.getHostAddress();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return "error";
    }

    //******
    //http://localhost:8000/health/ping
    //健康检查
    @RequestMapping(value = "ping", produces = { "application/json" })
    public Boolean Ping() {

        return true;
    }

}
