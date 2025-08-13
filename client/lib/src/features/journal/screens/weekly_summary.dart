// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import '/src/core/config/comic_api.dart';
// import '/src/features/journal/widgets/action_button.dart';
// import '/src/core/models/comic_response.dart';

// class WeeklySummary extends StatefulWidget {
//   const WeeklySummary({Key? key}) : super(key: key);

//   @override
//   _WeeklySummaryState createState() => _WeeklySummaryState();
// }

// class _WeeklySummaryState extends State<WeeklySummary> {
//   ComicApi comicApi = ComicApi();
//   ComicResponse? comicResponse;
//   bool isLoading = false;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchComic();
//   }

//   Future<void> _fetchComic() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });

//     try {
//       const prompt =
//           'Here is your weekly summary, presented as a manga-style comic strip. An astronaut floats peacefully before the large, sweeping window of the ISS. The face, full of quiet awe, is illuminated by the brilliant blue and white swirl of the Earth below...';
//       comicResponse = await comicApi.generateComic(prompt);
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to load comic: $e';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _shareWeeklySummary() {
//     // Implement sharing logic (e.g., share image URL or screenshot)
//     if (comicResponse != null) {
//       // Example: Share image path or URL
//       print('Sharing: ${comicResponse!.imagePath}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0x33667eea), Color(0x33764ba2)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'This Week\'s Journey',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF333333),
//                         ),
//                       ),
//                       ActionButton(
//                         icon: Icons.share,
//                         color: const Color(0xFF667eea),
//                         onPressed: _shareWeeklySummary,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 15),
//                   Container(
//                     height: 200,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: isLoading
//                         ? const Center(
//                             child: SpinKitFadingCircle(
//                               color: Color(0xFF667eea),
//                               size: 50.0,
//                             ),
//                           )
//                         : errorMessage.isNotEmpty
//                             ? Center(
//                                 child: Text(
//                                   errorMessage,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.red,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               )
//                             : comicResponse != null
//                                 ? CachedNetworkImage(
//                                     imageUrl: comicResponse!.imagePath,
//                                     placeholder: (context, url) => const Center(
//                                       child: SpinKitFadingCircle(
//                                         color: Color(0xFF667eea),
//                                         size: 50.0,
//                                       ),
//                                     ),
//                                     errorWidget: (context, url, error) =>
//                                         const Center(
//                                       child: Text(
//                                         'Failed to load image',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.red,
//                                         ),
//                                       ),
//                                     ),
//                                     fit: BoxFit.cover,
//                                   )
//                                 : const Center(
//                                     child: Text(
//                                       '🎨 AI-Generated Comic Summary',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontStyle: FontStyle.italic,
//                                         color: Color(0xFF666666),
//                                       ),
//                                     ),
//                                   ),
//                   ),
//                   const SizedBox(height: 15),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Navigate to full summary screen or open image in full view
//                       if (comicResponse != null) {
//                         print(
//                             'Viewing full summary: ${comicResponse!.imagePath}');
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF667eea),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                     ),
//                     child: const Text(
//                       'View Full Summary',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
