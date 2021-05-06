package kong.training.rest;

import kong.training.rest.model.Sex;
import kong.training.rest.model.User;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;

//MicroServiceTrain
@RestController
@EnableAutoConfiguration
@RequestMapping("user")
public class UserController {

	//******
	//http://localhost:8000/user/version
	//获取用户API服务版本
	@RequestMapping(value = "version", produces = { "application/json" })
	public String getVersion() {

		return "v1.0";//v2.0
	}


	 //******
	//http://localhost:8000/user?companyId=110100&name=11111112
	//根据用户ID/企业ID取得用户信息
	@RequestMapping(value = "", produces = { "application/json" })
	public User getUser(@RequestParam(value = "companyId", required = true) int companyId,
			@RequestParam(value = "name", required = true) String name,HttpServletRequest request) {

		User user = new User();
		user.setCompanyId(companyId);
		user.setName("tom");
		user.setSex(Sex.Male);
		user.setAge(20);
		user.setEmail("tom@mail.com");
		user.setLocation(request.getHeader("location"));
		return user;
	}

	// ****
	// http://localhost:8000/user/all/100010
	//根据企业ID取得所有用户信息
	@RequestMapping(value = "all/{companyId}", method = RequestMethod.GET)
	public List<User> getAllUser(@PathVariable("companyId") int companyId) {
		System.out.println(companyId);

		ArrayList<User> userList = new ArrayList<User>();
		User user = new User();
		user.setCompanyId(companyId);
		user.setName("tom");
		user.setSex(Sex.Male);
		user.setEmail("tom@mail.com");
		userList.add(user);

		user = new User();
		user.setName("lily");
		user.setSex(Sex.Female);
		user.setEmail("lily@mail.com");
		userList.add(user);

		return userList;
	}

	// ****
	//post man ->body raw json ->json value
	// http://localhost:8000/user?companyId=100010
	//  {"name":"tom","age":25}
	//添加用户
	@RequestMapping(value = "", method = RequestMethod.POST, headers = "Accept=application/json", produces = {
			"application/json" }, consumes = { "application/json" })
	public User addUser(@RequestParam(value = "companyId", required = true) int companyId, @RequestBody User user) {
		System.out.println(user);
		return user;
	}

	// *****
	// http://localhost:8000/user?companyId=100010&name=taotao
	//@ResponseBody
	//更新用户
	@RequestMapping(value = "", method = RequestMethod.PUT, produces = { "application/json" })
	public Boolean updateUser(@RequestParam(value = "companyId", required = true) int companyId,
			@RequestParam(value = "name", required = true) String name) {
		System.out.println(name);
		return true;
	}

	//******
	// http://localhost:8000/user?companyId=100010&name=111113
	//删除用户
	@RequestMapping(value = "", method = RequestMethod.DELETE, produces = {
			"application/json" })
	public Boolean deleteUser(@RequestParam(value = "companyId", required = true) int companyId,
			@RequestParam(value = "name", required = true, defaultValue = "Just a test!") String name) {

		System.out.println(companyId);
		System.out.println(name);
		return true;
	}

}
