package kong.training.rest.model;


public class User {

	private int companyId;

	private int userId;

	private int age;

	private String email;

	private String name;

	private Sex sex;

	private String position;

	private String location;

	private Boolean isFollow;

	private int online;

	private String createTime;

	private UserAvatar userAvatar;

	public User() {

	}
	

	public User(String name, int age) {
		this.name = name;
		this.age = age;

	}

	public int getCompanyId() {
		return companyId;
	}

	public void setCompanyId(int companyId) {
		this.companyId = companyId;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public int getAge() {
		return age;
	}

	public void setAge(int age) {
		this.age = age;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Sex getSex() {
		return sex;
	}

	public void setSex(Sex sex) {
		this.sex = sex;
	}

	public String getPosition() {
		return position;
	}

	public void setPosition(String position) {
		this.position = position;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public Boolean getIsFollow() {
		return isFollow;
	}

	public void setIsFollow(Boolean isFollow) {
		this.isFollow = isFollow;
	}

	public int getOnline() {
		return online;
	}

	public void setOnline(int online) {
		this.online = online;
	}

	public String getCreateTime() {
		return createTime;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public UserAvatar getUserAvatar() {
		return userAvatar;
	}

	public void setUserAvatar(UserAvatar userAvatar) {
		this.userAvatar = userAvatar;
	}

}