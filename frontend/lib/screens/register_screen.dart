import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _tenants = [];
  String? _selectedTenantId;

  @override
  void initState() {
    super.initState();
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    try {
      final tenants = await ApiService.fetchTenants();
      setState(() {
        _tenants = tenants;
        if (_tenants.isNotEmpty) {
          _selectedTenantId = _tenants[0]['id'];
        }
      });
    } catch (e) {
      print('Failed to fetch tenants: $e');
    }
  }

  Future<void> _showFirstTenantSignupDialog() async {
    final formKey = GlobalKey<FormState>();
    final tenantNameController = TextEditingController();
    final tenantContactEmailController = TextEditingController();
    final ownerEmailController = TextEditingController();
    final ownerUsernameController = TextEditingController();
    final ownerPasswordController = TextEditingController();
    bool isSubmitting = false;
    String? error;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('First Tenant Signup'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: tenantNameController,
                        decoration: const InputDecoration(labelText: 'Tenant Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter tenant name' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: tenantContactEmailController,
                        decoration: const InputDecoration(labelText: 'Tenant Contact Email'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter contact email' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: ownerEmailController,
                        decoration: const InputDecoration(labelText: 'Owner Email'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter owner email' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: ownerUsernameController,
                        decoration: const InputDecoration(labelText: 'Owner Username'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter owner username' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: ownerPasswordController,
                        decoration: const InputDecoration(labelText: 'Owner Password'),
                        obscureText: true,
                        validator: (v) => v == null || v.length < 6 ? 'Password min 6 chars' : null,
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(error!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isSubmitting = true);
                            try {
                              final resp = await ApiService.signupClient(
                                tenantName: tenantNameController.text,
                                tenantContactEmail: tenantContactEmailController.text,
                                ownerEmail: ownerEmailController.text,
                                ownerUsername: ownerUsernameController.text,
                                ownerPassword: ownerPasswordController.text,
                              );
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tenant and owner created! Logging in...')),
                                );
                                Navigator.of(context).pushReplacementNamed('/home');
                              }
                            } catch (e) {
                              setState(() {
                                isSubmitting = false;
                                error = e.toString();
                              });
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Signup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _selectedTenantId != null) {
      setState(() => _isLoading = true);
      try {
        print('Attempting registration for email: ${_emailController.text}');
        print('Username: ${_usernameController.text}');
        
        final response = await ApiService.register(
          _emailController.text,
          _usernameController.text,
          _passwordController.text,
          _selectedTenantId!,
        );
        
        print('Registration successful. User data: $response');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please login.')),
          );
          Navigator.pop(context); // Return to login screen
        }
      } catch (e) {
        print('Registration failed with error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _tenants.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const Text('No tenants found. Be the first to create your organization!', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showFirstTenantSignupDialog,
                    child: const Text('First Tenant Signup'),
                  ),
                ],
              )
            : Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedTenantId,
                      items: _tenants.map<DropdownMenuItem<String>>((tenant) {
                        return DropdownMenuItem<String>(
                          value: tenant['id'],
                          child: Text(tenant['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTenantId = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Tenant',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) => value == null ? 'Please select a tenant' : null,
                    ),
                    const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Register'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
} 