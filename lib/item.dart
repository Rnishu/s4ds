import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Item extends StatelessWidget {
  final Map<String, dynamic> item;
  Item(this.item) : super(key: ValueKey<int>(item["id"]));
  @override
  Widget build(BuildContext context) {
    //double screenRatio = MediaQuery.of(context).devicePixelRatio;
    String title = item['title'];
    String description = item['description'];
    double price = item['price'];
    double discountPercentage = item['discountPercentage'];
    double discountPrice =
        ((100 - discountPercentage) * price * 0.01).roundToDouble();
    double rating = item['rating'];
    int stock = item['stock'];
    String brand = item['brand'];
    String category = item['category'];
    Image thumbnail = Image.network(item['thumbnail'],
        key: ValueKey<int>(item['id']),
        height: 0.1 * MediaQuery.of(context).size.width);
    //List<Image> images = item['images'].map((image) => Image.network(image));
    return Container(
      key: super.key,
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: stock > 0 ? Colors.grey : Colors.red),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          thumbnail,
          Text(
            description.length > 30
                ? "${description.substring(0, 40)}..."
                : description,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.left,
          ),
          Row(
            children: [
              Text("₹$discountPrice ",
                  style: const TextStyle(color: Colors.white, fontSize: 25)),
              Text(
                "  ₹$price  ",
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontSize: 15),
              ),
              Text(
                "($discountPercentage%)",
                style: const TextStyle(color: Colors.grey, fontSize: 20),
              ),
            ],
          ),
          Text(
            brand,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.left,
          ),
          Text(
            category,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.left,
          ),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 30.0,
            direction: Axis.horizontal,
          ),
        ],
      ),
    );
  }
}
