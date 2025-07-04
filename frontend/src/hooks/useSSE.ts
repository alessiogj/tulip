import { useEffect, useRef } from 'react';
import { API_BASE_PATH } from '../const';

interface SSEMessage {
  type: 'update' | 'heartbeat' | 'error';
  timestamp: number;
  flowCount?: number;
  message?: string;
}

export function useSSE(onUpdate: () => void) {
  const eventSourceRef = useRef<EventSource | null>(null);

  useEffect(() => {
    // Connessione agli eventi SSE
    const eventSource = new EventSource(`${API_BASE_PATH}/events`);
    eventSourceRef.current = eventSource;

    eventSource.onmessage = (event) => {
      try {
        const data: SSEMessage = JSON.parse(event.data);
        
        if (data.type === 'update') {
          console.log('Nuovi flussi ricevuti:', data.flowCount);
          onUpdate(); // Triggera il refetch dei dati
        } else if (data.type === 'heartbeat') {
          console.log('SSE heartbeat ricevuto');
        } else if (data.type === 'error') {
          console.error('Errore SSE:', data.message);
        }
      } catch (error) {
        console.error('Errore parsing SSE message:', error);
      }
    };

    eventSource.onerror = (event) => {
      console.error('Errore connessione SSE:', event);
    };

    eventSource.onopen = () => {
      console.log('Connessione SSE aperta');
    };

    // Cleanup quando il componente viene smontato
    return () => {
      eventSource.close();
    };
  }, [onUpdate]);

  return {
    close: () => {
      eventSourceRef.current?.close();
    }
  };
} 