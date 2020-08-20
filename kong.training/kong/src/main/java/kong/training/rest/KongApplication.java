package kong.training.rest;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class KongApplication {

	public static void main(String[] args) {
        //mvn package
		//mvn clean package  -Dmaven.test.skip=true
		//java -jar
		SpringApplication.run(KongApplication.class, args);
	}

    /*
	public static void main(String[] args) throws Exception {
		ConfigurableApplicationContext context = SpringApplication.run(UDPReceiveConfig.class, args);
		Thread.sleep(60*1000*10);
		context.close();
	}
     */


}
