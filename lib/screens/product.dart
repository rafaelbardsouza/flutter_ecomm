import 'package:flutter/material.dart';
import 'package:flutter_ecomm/database/product_model.dart';

class ProductScreen extends StatefulWidget {
  final ProductModel product;

  ProductScreen({required this.product});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isExpanded = false;
  final int _descriptionMaxLines = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.product.imageUrl),
            SizedBox(height: 16.0),
            Text(
              widget.product.title,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '\$${widget.product.price}',
              style: TextStyle(fontSize: 20.0, color: Colors.green),
            ),
            SizedBox(height: 8.0),
            _buildExpandableDescription(),
            SizedBox(height: 16.0),
            Text(
              'Category: ${widget.product.category ?? "N/A"}',
              style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow),
                SizedBox(width: 4.0),
                Text(
                  '${widget.product.rating?.rate ?? "0.0"} (${widget.product.rating?.count ?? 0} reviews)',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableDescription() {
    final description =
        widget.product.description ?? "No description available.";
    final textSpan = TextSpan(
      text: description,
      style: TextStyle(fontSize: 16.0),
    );

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: _descriptionMaxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      maxWidth: MediaQuery.of(context).size.width - 32.0,
    );

    final isOverflowing = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: TextStyle(fontSize: 16.0),
          maxLines: _isExpanded ? null : _descriptionMaxLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (isOverflowing)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show less' : 'Show more',
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}
