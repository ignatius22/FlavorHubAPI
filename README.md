# FlavorHub API
A Ruby on Rails API for food ordering, featuring role-based access, order management with extras, and shipment tracking—deployed with AWS, Docker, and CI/CD.

## Overview
FlavorHub API powers a food ordering platform, connecting customers, restaurant admins, and delivery teams. Built with Ruby on Rails, it leverages service objects for clean logic, serializers for structured responses, and a robust PostgreSQL schema. With AWS-hosted CI/CD, it’s a showcase of my ability to deliver scalable, maintainable backends—perfect for SaaS innovators like OnTheGoSystems’ PTC or GitLab’s DevSecOps ecosystem.

## Features
- **Role-Based Access**: Supports `user`, `admin` roles with JWT authentication for secure endpoints.  
- **Order Management**: Create and track orders with statuses (`pending`, `shipped`, etc.), nested items, and extras.  
- **Product Catalog**: Manage products with pricing, favorites, and visibility toggles (`active`, `visible`).  
- **Shipment Tracking**: Update and monitor order statuses via API (e.g., `/orders/:id/ship`).  
- **User Profiles**: Self-service profile updates with avatar, address, and bio.  
- **Favorites**: Customers can mark favorite products, tracked in a many-to-many relationship.  

## Tech Stack
- **Backend**: Ruby on Rails 7  
- **Database**: PostgreSQL (with `plpgsql` extension)  
- **Authentication**: JWT (`jwt` gem)  
- **Security**: `bcrypt` for password hashing  
- **Background Jobs**: Sidekiq (mounted at `/sidekiq`)  
- **Service Objects**: Encapsulate business logic (e.g., order creation, status updates)  
- **Serializers**: Active Model Serializers for clean JSON responses  
- **DevOps**: AWS (ECS, RDS), Docker, CI/CD (GitHub Actions)  
- **Testing**: RSpec  

## Setup Instructions
### Local Development
1. **Clone the Repository**:  
   ```bash
   git clone https://github.com/ignatius22/flavorhub-api.git
   cd flavorhub-api
