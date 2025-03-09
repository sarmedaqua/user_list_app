
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_providers.dart';
import '../widgets/user_list_item.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import 'user_detail_screen.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).getUsers();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(userProvider.notifier).getUsers();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.95);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users List App'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(userProvider.notifier).clearSearch();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                ref.read(userProvider.notifier).searchUsers(value);
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userProvider.notifier).getUsers(refresh: true);
        },
        child: Builder(
          builder: (context) {
            if (userState.failure != null && userState.users.isEmpty) {
              return CustomErrorWidget(
                message: userState.failure!.message,
                onRetry: () {
                  ref.read(userProvider.notifier).getUsers(refresh: true);
                },
              );
            }

            if (userState.users.isEmpty && userState.isLoading) {
              return const LoadingWidget();
            }

            final filteredUsers = userState.filteredUsers;

            if (filteredUsers.isEmpty && userState.searchQuery.isNotEmpty) {
              return const Center(
                child: Text('No users found matching your search criteria.'),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: filteredUsers.length + (userState.isLoading && !userState.hasReachedMax ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= filteredUsers.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = filteredUsers[index];
                return UserListItem(
                  user: user,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailScreen(user: user),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}