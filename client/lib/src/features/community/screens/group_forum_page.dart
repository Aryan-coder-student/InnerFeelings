// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../widgets/data_models.dart';
// import '/src/features/new_entry.dart';

// class GroupForumPage extends StatefulWidget {
//   final CommunityGroup group;
//   const GroupForumPage({super.key, required this.group});

//   @override
//   State<GroupForumPage> createState() => _GroupForumPageState();
// }

// class _GroupForumPageState extends State<GroupForumPage> {
//   final List<Post> posts = [];
//   final TextEditingController _controller = TextEditingController();
//   XFile? _pickedImage;

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final image = await picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       _pickedImage = image;
//     });
//   }

//   void _createPost() {
//     if (_controller.text.isEmpty && _pickedImage == null) return;
//     setState(() {
//       posts.add(Post(
//         id: DateTime.now().toString(),
//         authorName: 'You',
//         authorAvatar: '',
//         content: _controller.text,
//         imageUrl: _pickedImage?.path,
//         videoUrl: null,
//         timestamp: DateTime.now(),
//         groupId: widget.group.id,
//         comments: [],
//       ));
//       _controller.clear();
//       _pickedImage = null;
//     });
//   }

//   void _addComment(Post post, String commentText) {
//     setState(() {
//       post.comments.add(Comment(
//         id: DateTime.now().toString(),
//         authorName: 'You',
//         authorAvatar: '',
//         content: commentText,
//         timestamp: DateTime.now(),
//       ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.group.name),
//         backgroundColor: widget.group.color,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: posts.length,
//               itemBuilder: (context, idx) {
//                 final post = posts[idx];
//                 return Card(
//                   margin: const EdgeInsets.all(8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(post.authorName,
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.bold)),
//                         if (post.content.isNotEmpty) Text(post.content),
//                         if (post.imageUrl != null)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Image.file(
//                               // ignore: deprecated_member_use
//                               File(post.imageUrl!),
//                               height: 150,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         const SizedBox(height: 8),
//                         ...post.comments.map((c) => Padding(
//                               padding: const EdgeInsets.only(left: 8, top: 4),
//                               child: Text('${c.authorName}: ${c.content}',
//                                   style: const TextStyle(fontSize: 13)),
//                             )),
//                         _CommentInput(
//                           onComment: (txt) => _addComment(post, txt),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                         hintText: 'Share your thoughts...'),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.image),
//                   onPressed: _pickImage,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _createPost,
//                 ),
//               ],
//             ),
//           ),
//           if (_pickedImage != null)
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: Image.file(
//                 // ignore: deprecated_member_use
//                 File(_pickedImage!.path),
//                 height: 80,
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.edit),
//         onPressed: () {
//           // Navigate to journal entry page for today
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => JournalEntryPage(date: DateTime.now()),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _CommentInput extends StatefulWidget {
//   final Function(String) onComment;
//   const _CommentInput({required this.onComment});

//   @override
//   State<_CommentInput> createState() => __CommentInputState();
// }

// class __CommentInputState extends State<_CommentInput> {
//   final TextEditingController _commentController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             controller: _commentController,
//             decoration: const InputDecoration(hintText: 'Add a comment...'),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.send, size: 18),
//           onPressed: () {
//             if (_commentController.text.isNotEmpty) {
//               widget.onComment(_commentController.text);
//               _commentController.clear();
//             }
//           },
//         ),
//       ],
//     );
//   }
// }

// class JournalEntryPage extends StatelessWidget {
//   final DateTime date;
//   const JournalEntryPage({super.key, required this.date});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Journal Entry'),
//       ),
//       body: Center(
//         child: Text('Journal entry for ${date.toLocal()}'),
//       ),
//     );
//   }
// }
