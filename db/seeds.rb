# Ensure the existence of users
user1 = User.find_or_create_by!(email: 'alice@example.com') do |user|
  user.password = 'password123'
  user.username = 'alice'
  user.role = 'admin'
end

user2 = User.find_or_create_by!(email: 'bob@example.com') do |user|
  user.password = 'password123'
  user.username = 'bob'
  user.role = 'user'
end

user3 = User.find_or_create_by!(email: 'carol@example.com') do |user|
  user.password = 'password123'
  user.username = 'carol'
  user.role = 'user'
end

user4 = User.find_or_create_by!(email: 'dave@example.com') do |user|
  user.password = 'password123'
  user.username = 'dave'
  user.role = 'moderator'
end

# Ensure profiles are associated with users
Profile.find_or_create_by!(user: user1) do |profile|
  profile.first_name = 'Alice'
  profile.last_name = 'Johnson'
  profile.bio = 'A passionate software engineer with a love for open-source projects.'
  profile.avatar = 'https://example.com/avatars/alice.jpg'
  profile.phone_number = '555-1234'
  profile.address = '123 Main St, Anytown, USA'
end

Profile.find_or_create_by!(user: user2) do |profile|
  profile.first_name = 'Bob'
  profile.last_name = 'Smith'
  profile.bio = 'An experienced backend developer and database specialist.'
  profile.avatar = 'https://example.com/avatars/bob.jpg'
  profile.phone_number = '555-5678'
  profile.address = '456 Oak St, Sometown, USA'
end

Profile.find_or_create_by!(user: user3) do |profile|
  profile.first_name = 'Carol'
  profile.last_name = 'White'
  profile.bio = 'A UI/UX designer with a knack for creating intuitive user experiences.'
  profile.avatar = 'https://example.com/avatars/carol.jpg'
  profile.phone_number = '555-9101'
  profile.address = '789 Pine St, Yourtown, USA'
end

Profile.find_or_create_by!(user: user4) do |profile|
  profile.first_name = 'Dave'
  profile.last_name = 'Brown'
  profile.bio = 'A DevOps engineer who enjoys automating everything.'
  profile.avatar = 'https://example.com/avatars/dave.jpg'
  profile.phone_number = '555-1122'
  profile.address = '101 Maple St, Thistown, USA'
end

# Ensure products are created with user associations
products = [
  {
    title: 'Classic Cheeseburger',
    price: 8.99,
    delivery_fee: 2.50,
    duration: 30,
    image: 'https://example.com/images/classic_cheeseburger.jpg',
    status: 'active',
    visibility: 'visible',
    calories: 700,
    rating: 4.5,
    user_id: user1.id
  },
  {
    title: 'Bacon Double Burger',
    price: 10.99,
    delivery_fee: 2.50,
    duration: 30,
    image: 'https://example.com/images/bacon_double_burger.jpg',
    status: 'active',
    visibility: 'visible',
    calories: 950,
    rating: 4.8,
    user_id: user2.id
  },
  {
    title: 'Veggie Burger',
    price: 7.99,
    delivery_fee: 2.50,
    duration: 25,
    image: 'https://example.com/images/veggie_burger.jpg',
    status: 'inactive',
    visibility: 'hidden',
    calories: 600,
    rating: 4.3,
    user_id: user3.id
  },
  {
    title: 'Mushroom Swiss Burger',
    price: 10.49,
    delivery_fee: 2.50,
    duration: 30,
    image: 'https://example.com/images/mushroom_swiss_burger.jpg',
    visibility: 'visible',
    calories: 800,
    rating: 4.7,
    user_id: user4.id
  }
]

products.each do |product_attrs|
  product = Product.find_or_create_by!(title: product_attrs[:title]) do |p|
    p.assign_attributes(product_attrs)
  end

  case product.title
  when 'Classic Cheeseburger'
    product.product_extras.find_or_create_by!(name: 'Ketchup', quantity: 1)
    product.product_extras.find_or_create_by!(name: 'Mustard', quantity: 1)
    product.product_extras.find_or_create_by!(name: 'Pickles', quantity: 2)
  when 'Bacon Double Burger'
    product.product_extras.find_or_create_by!(name: 'Ketchup', quantity: 1)
    product.product_extras.find_or_create_by!(name: 'Bacon', quantity: 2)
    product.product_extras.find_or_create_by!(name: 'Cheese', quantity: 2)
  when 'Veggie Burger'
    product.product_extras.find_or_create_by!(name: 'Lettuce', quantity: 2)
    product.product_extras.find_or_create_by!(name: 'Tomato', quantity: 2)
    product.product_extras.find_or_create_by!(name: 'Avocado', quantity: 1)
  when 'Mushroom Swiss Burger'
    product.product_extras.find_or_create_by!(name: 'Mushrooms', quantity: 2)
    product.product_extras.find_or_create_by!(name: 'Swiss Cheese', quantity: 2)
  end
end

# Ensure orders are created for the first and second users
order1 = Order.find_or_create_by!(user: user1, total_price: 19.98, status: 'pending')
order2 = Order.find_or_create_by!(user: user2, total_price: 59.98, status: 'shipped')

# Ensure order items are created for the orders
OrderItem.find_or_create_by!(order: order1, product: Product.find_by(title: 'Classic Cheeseburger')) do |item|
  item.quantity = 1
  item.price = Product.find_by(title: 'Classic Cheeseburger').price
  item.total = item.price * item.quantity
end

OrderItem.find_or_create_by!(order: order1, product: Product.find_by(title: 'Mushroom Swiss Burger')) do |item|
  item.quantity = 1
  item.price = Product.find_by(title: 'Mushroom Swiss Burger').price
  item.total = item.price * item.quantity
end

OrderItem.find_or_create_by!(order: order2, product: Product.find_by(title: 'Bacon Double Burger')) do |item|
  item.quantity = 1
  item.price = Product.find_by(title: 'Bacon Double Burger').price
  item.total = item.price * item.quantity
end

OrderItem.find_or_create_by!(order: order2, product: Product.find_by(title: 'Veggie Burger')) do |item|
  item.quantity = 1
  item.price = Product.find_by(title: 'Veggie Burger').price
  item.total = item.price * item.quantity
end
