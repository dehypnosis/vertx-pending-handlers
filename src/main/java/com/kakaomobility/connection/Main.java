package com.kakaomobility.connection;

import io.vertx.core.Vertx;
import io.vertx.core.VertxOptions;
import io.vertx.core.eventbus.DeliveryOptions;
import io.vertx.ext.web.Router;
import io.vertx.micrometer.MicrometerMetricsOptions;
import io.vertx.micrometer.PrometheusScrapingHandler;
import io.vertx.micrometer.VertxPrometheusOptions;
import io.vertx.micrometer.backends.BackendRegistries;
import lombok.extern.log4j.Log4j2;

@Log4j2
public class Main {
    public static void main(String[] args) {
        // setup metrics registry
        var registry = BackendRegistries.setupBackend(
                new MicrometerMetricsOptions()
                        .setPrometheusOptions(new VertxPrometheusOptions().setEnabled(true))
                        .setRegistryName("demo")).getMeterRegistry();

        // create vertx
        var vertx = Vertx.vertx(
                new VertxOptions()
                        .setMetricsOptions(new MicrometerMetricsOptions().setMicrometerRegistry(registry).setEnabled(true))
            );

        // periodically create consumer and unregister
        var eventBus = vertx.eventBus();
        var consumerTimer = vertx.setPeriodic(1000, v -> {
            var consumer = eventBus.<String>consumer("topic");
            consumer.handler(event -> {
                // do nothing
            });
            log.info("consumer registered");
            vertx.setTimer(500, vv -> {
                consumer.unregister(vvv -> {
                    log.info("consumer unregistered");
                });
            });
        });

        // provide stream of string
        var providerTimer = vertx.setPeriodic(10, v -> {
            for (var i=0; i<10000; i++) {
                var data = String.valueOf(Math.random());
                var options = new DeliveryOptions()
                        .setLocalOnly(true)
                        .setSendTimeout(1000);
                eventBus.request("topic", data, options);
            }
            log.info("published 10k data");
        });

        // kill all logics after 10s
        vertx.setTimer(1000*10, v -> {
            vertx.cancelTimer(providerTimer);
            log.info("provider stopped");
        });

        // mount server
        var router = Router.router(vertx);
        router.get("/").handler(PrometheusScrapingHandler.create("demo"));
        var server = vertx.createHttpServer();
        server
                .requestHandler(router)
                .exceptionHandler(log::error)
                .listen(8080, "0.0.0.0");
    }
}