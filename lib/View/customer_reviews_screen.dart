// customer_reviews_screen.dart - Updated with Figma color scheme
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controls/crm_service.dart';
import '../Model/customer.dart';
import '../Model/customer_review.dart';


class CustomerReviewsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerReviewsScreen({Key? key, required this.customer}) : super(key: key);

  @override
  _CustomerReviewsScreenState createState() => _CustomerReviewsScreenState();
}

class _CustomerReviewsScreenState extends State<CustomerReviewsScreen> {
  final CrmService _crmService = CrmService();
  final TextEditingController _reviewController = TextEditingController();
  List<CustomerReview> _reviews = [];
  bool _isLoading = true;
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    try {
      print('DEBUG: Loading reviews for customer ID: ${widget.customer.id}');
      final reviews = await _crmService.getCustomerReviews(widget.customer.id!);
      print('DEBUG: Found ${reviews.length} reviews');
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error loading reviews: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a review'),
          backgroundColor: Colors.orange[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      final review = CustomerReview(
        customerId: widget.customer.id,
        rating: _selectedRating,
        reviewText: _reviewController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _crmService.addCustomerReview(review);
      _reviewController.clear();
      _selectedRating = 5;
      _loadReviews();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review added successfully'),
          backgroundColor: Color(0xFF2A9D8F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding review: $e'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3B4C68), // Dark blue background from Figma
      appBar: AppBar(
        title: Text('Customer Reviews', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF3B4C68),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Customer Header
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              widget.customer.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Add Review Section
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Review',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),

                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star,
                          color: index < _selectedRating ? Colors.amber[400] : Colors.grey[300],
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 16),

                // Review Text Field
                TextFormField(
                  controller: _reviewController,
                  maxLines: 3,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Write your review...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    fillColor: Colors.grey[50],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF2A9D8F), width: 2),
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),

                SizedBox(height: 16),

                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2A9D8F),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Add Review',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reviews List
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Previous Reviews',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),

                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F)))
                        : _reviews.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text(
                            'No reviews yet',
                            style: TextStyle(color: Colors.grey[500], fontSize: 16),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return _buildReviewItem(review);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(CustomerReview review) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: index < review.rating ? Colors.amber[400] : Colors.grey[300],
                    size: 18,
                  );
                }),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(review.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Review Text
          Text(
            review.reviewText,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}