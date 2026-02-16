import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FlaskServiceService } from '../../services/flask-service.service';

@Component({
  selector: 'app-orders',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './orders.component.html',
  styleUrls: ['./orders.component.css']
})
export class OrdersComponent implements OnInit {
  orders: any[] = [];
  loading = false;
  error = '';
  selectedStatus = 'pending';
  expandedOrderId: number | null = null;

  constructor(private flaskService: FlaskServiceService) {}

  ngOnInit() {
    this.loadOrders();
  }

  loadOrders() {
    this.loading = true;
    this.flaskService.getOrdersByStatus(this.selectedStatus).subscribe({
      next: (response) => {
        this.orders = response.data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Errore caricamento ordini';
        this.loading = false;
      }
    });
  }

  onStatusChange() {
    this.loadOrders();
  }

  updateOrderStatus(orderId: number, newStatus: string) {
    this.flaskService.updateOrderStatus(orderId, newStatus).subscribe({
      next: (response) => {
        this.loadOrders();
      },
      error: (err) => {
        this.error = 'Errore aggiornamento ordine';
      }
    });
  }

  toggleExpandOrder(orderId: number) {
    this.expandedOrderId = this.expandedOrderId === orderId ? null : orderId;
  }

  getNextStatus(currentStatus: string): string {
    const statuses = ['pending', 'preparing', 'ready', 'delivered'];
    const index = statuses.indexOf(currentStatus);
    return index < statuses.length - 1 ? statuses[index + 1] : currentStatus;
  }

  getStatusLabel(status: string): string {
    const labels: { [key: string]: string } = {
      'pending': '⏳ In Attesa',
      'preparing': '👨‍🍳 In Preparazione',
      'ready': '✅ Pronto',
      'delivered': '🎉 Consegnato'
    };
    return labels[status] || status;
  }
}
